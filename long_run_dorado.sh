#!/bin/bash

# --- KONFIGURASI ---
MODEL_PATH="dna_r10.4.1_e8.2_400bps_hac@v5.2.0"  # Ganti dengan path model
INPUT_DIR="/path/to/pod5_pass"                    # Ganti dengan path pod5
DORADO_EXE="./dorado"                              # Ganti dengan path Dorado
OUTPUT="/path/to/output-dorado"                    # Ganti dengan path output
DAYS=7                                             # Ganti dengan durasi (7 hari)

# Fungsi untuk logging dengan timestamp
log_info() {
    echo -e "\033[36m[$(date '+%H:%M:%S')] $1\033[0m"
}

log_warn() {
    echo -e "\033[33m[$(date '+%H:%M:%S')] $1\033[0m"
}

log_success() {
    echo -e "\033[32m[$(date '+%H:%M:%S')] $1\033[0m"
}

# Fungsi untuk membersihkan background processes
cleanup() {
    log_info "Membersihkan background processes..."
    if [[ -n "$GPU_PID" ]]; then
        kill $GPU_PID 2>/dev/null || true
    fi
    exit 0
}

# Set trap untuk cleanup saat script dihentikan
trap cleanup EXIT INT TERM

# Validasi direktori output
if [[ ! -d "$OUTPUT" ]]; then
    mkdir -p "$OUTPUT"
    log_info "Direktori output dibuat: $OUTPUT"
fi

# Validasi direktori input
if [[ ! -d "$INPUT_DIR" ]]; then
    log_warn "Direktori input tidak ditemukan: $INPUT_DIR"
    exit 1
fi

# Validasi executable Dorado
if [[ ! -f "$DORADO_EXE" ]]; then
    log_warn "Executable Dorado tidak ditemukan: $DORADO_EXE"
    exit 1
fi

# Hitung waktu berhenti (7 hari dari sekarang)
END_TIME=$(date -d "+$DAYS days" +%s)
log_info "Looping dimulai. Akan berakhir pada: $(date -d @$END_TIME)"

# Loop utama
while [[ $(date +%s) -lt $END_TIME ]]; do
    # Buat timestamp unik (TahunBulanHari_JamMenitDetik)
    TS=$(date '+%Y%m%d_%H%M%S')
    
    OUT_BAM="$OUTPUT/calls_$TS.bam"
    DORADO_LOG="$OUTPUT/dorado_$TS.log"
    GPU_LOG="$OUTPUT/gpu_stats_$TS.csv"
    
    log_warn "Memulai proses: $OUT_BAM"
    
    # 1. Jalankan Logging GPU (nvidia-smi) di background
    # Mencatat: Waktu, Nama GPU, Suhu, Penggunaan GPU, Penggunaan Memori, & Daya (Power Draw)
    nvidia-smi --query-gpu=timestamp,name,temperature.gpu,utilization.gpu,utilization.memory,power.draw --format=csv -l 1 > "$GPU_LOG" 2>/dev/null &
    GPU_PID=$!
    
    # 2. Jalankan Dorado Basecalling
    # Menggunakan --verbose di log (opsional) agar info lebih detail
    log_info "Menjalankan Dorado basecalling..."
    "$DORADO_EXE" basecaller "$MODEL_PATH" "$INPUT_DIR" > "$OUT_BAM" 2> "$DORADO_LOG"
    DORADO_STATUS=$?
    
    # 3. Hentikan Logging GPU setelah Dorado selesai
    if [[ -n "$GPU_PID" ]] && kill -0 "$GPU_PID" 2>/dev/null; then
        kill $GPU_PID 2>/dev/null || true
    fi
    
    if [[ $DORADO_STATUS -eq 0 ]]; then
        log_success "Selesai. Output: $OUT_BAM | Log: $DORADO_LOG"
    else
        log_warn "Dorado basecalling gagal dengan status: $DORADO_STATUS"
    fi
    
    # Jeda singkat sebelum loop berikutnya
    sleep 5
done

log_info "Durasi $DAYS hari telah terpenuhi. Script berhenti."
exit 0