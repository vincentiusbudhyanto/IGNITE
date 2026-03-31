# --- KONFIGURASI ---
$MODEL_PATH = "dna_r10.4.1_e8.2_400bps_hac@v5.2.0"  # Ganti dengan path model
$INPUT_DIR = "D:\pod5_pass"   # Ganti dengan path pod5
$DORADO_EXE = ".\dorado.exe"  # Ganti dengan path Dorado
$OUTPUT = "D:\output-dorado"  # Ganti dengan path output
$DAYS = 7  # Ganti dengan durasi (7 hari)

# Tentukan waktu berhenti (7 hari dari sekarang)
$EndTime = (Get-Date).AddDays($DAYS)
Write-Host "Looping dimulai. Akan berakhir pada: $EndTime" -ForegroundColor Cyan

while ((Get-Date) -lt $EndTime) {
    # Buat timestamp unik (TahunBulanHari_JamMenitDetik)
    $TS = Get-Date -Format "yyyyMMdd_HHmmss"
    
    $OutBam = "$OUTPUT\calls_$TS.bam"
    $DoradoLog = "$OUTPUT\dorado_$TS.log"
    $GpuLog = "$OUTPUT\gpu_stats_$TS.csv"

    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Memulai proses: $OutBam" -ForegroundColor Yellow

    # 1. Jalankan Logging GPU (nvidia-smi) di background
    # Mencatat: Waktu, Nama GPU, Suhu, Penggunaan GPU, Penggunaan Memori, & Daya (Power Draw)
    $GpuProcess = Start-Process nvidia-smi -ArgumentList "--query-gpu=timestamp,name,temperature.gpu,utilization.gpu,utilization.memory,power.draw --format=csv -l 1" `
                  -RedirectStandardOutput $GpuLog -NoNewWindow -PassThru

    # 2. Jalankan Dorado Basecalling
    # Menggunakan --verbose di log (opsional) agar info lebih detail
    & $DORADO_EXE basecaller $MODEL_PATH $INPUT_DIR > $OutBam 2> $DoradoLog

    # 3. Hentikan Logging GPU setelah Dorado selesai
    if ($GpuProcess) {
        Stop-Process -Id $GpuProcess.Id -Force -ErrorAction SilentlyContinue
    }

    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Selesai. Output: $OutBam | Log: $DoradoLog" -ForegroundColor Green
    
    # Jeda singkat sebelum loop berikutnya
    Start-Sleep -Seconds 5
}

Write-Host "Durasi 7 hari telah terpenuhi. Script berhenti." -ForegroundColor White
