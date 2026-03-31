# Panduan Dorado Basecalling ONT – Windows & Ubuntu

Skrip PowerShell `long_run_dorado.ps1` dan Bash `long_run_dorado.sh` menjalankan basecalling berkelanjutan selama 7 hari (atau sesuai `$DAYS`/`$DAYS`) sambil mencatat stat GPU setiap detik. Output berupa file `.bam` dan log GPU per batch.

## Ringkas Cepat
- **Windows**: Gunakan `long_run_dorado.ps1` (PowerShell)
- **Ubuntu/Linux**: Gunakan `long_run_dorado.sh` (Bash) - [sudah tersedia ✓]

## Persiapan Umum

1. GPU NVIDIA + driver terbaru  
2. CUDA Toolkit ≥ 11.8 (Windows) atau ≥ 12.x (Ubuntu)  
3. Model basecaller ONT (`.cfg` atau `.zip`) – unduh dari [Oxford Nanopore](https://nanoporetech.com)  
4. Folder POD5 input & folder output yang ditentukan

## Download Model Basecaller ONT

Model basecaller tersedia dalam berbagai ukuran dan akurasi. Berikut cara download model yang umum digunakan:

### Model Populer untuk R10.4.1:
- **HAC (High Accuracy)**: `dna_r10.4.1_e8.2_400bps_hac@v5.2.0`
- **SUP (Super High Accuracy)**: `dna_r10.4.1_e8.2_400bps_sup@v5.2.0`
- **FAST (Fast)**: `dna_r10.4.1_e8.2_400bps_fast@v5.2.0`

### Cara Download Model (Recommended):

Gunakan perintah `dorado download` untuk download otomatis:

#### Windows (PowerShell):
```powershell
# Download model HAC (High Accuracy)
cd C:\dorado
.\dorado.exe download --model dna_r10.4.1_e8.2_400bps_hac@v5.2.0 --models-directory .\models

# Hasil: folder C:\dorado\models\dna_r10.4.1_e8.2_400bps_hac@v5.2.0\
```

#### Ubuntu/Linux (Bash):
```bash
# Download model HAC (High Accuracy)
cd ~/dorado
./dorado download --model dna_r10.4.1_e8.2_400bps_hac@v5.2.0 --models-directory ./models

# Hasil: folder ~/dorado/models/dna_r10.4.1_e8.2_400bps_hac@v5.2.0/
```

### Alternatif: Download Manual
Jika perintah `dorado download` tidak tersedia, gunakan cara manual:

#### Windows (PowerShell):
```powershell
# Buat folder model
mkdir C:\dorado\models
cd C:\dorado\models

# Download model HAC (High Accuracy)
Invoke-WebRequest -Uri "https://cdn.oxfordnanoportal.com/software/analysis/dorado_models/dna_r10.4.1_e8.2_400bps_hac@v5.2.0.zip" -OutFile "dna_r10.4.1_e8.2_400bps_hac@v5.2.0.zip"

# Extract model
Expand-Archive "dna_r10.4.1_e8.2_400bps_hac@v5.2.0.zip" -DestinationPath "."
```

#### Ubuntu/Linux (Bash):
```bash
# Buat folder model
mkdir -p ~/dorado/models
cd ~/dorado/models

# Download model HAC (High Accuracy)
wget "https://cdn.oxfordnanoportal.com/software/analysis/dorado_models/dna_r10.4.1_e8.2_400bps_hac@v5.2.0.zip"

# Extract model
unzip "dna_r10.4.1_e8.2_400bps_hac@v5.2.0.zip"
```

### List Model Lengkap:
Untuk melihat semua model yang tersedia, kunjungi:
- [Official Dorado Models](https://github.com/nanoporetech/dorado#models)
- [Oxford Nanopore Support](https://community.nanoporetech.com)

### Tips Pemilihan Model:
- **FAST**: Kecepatan tinggi, akurasi menengah – cocok untuk screening cepat
- **HAC**: Keseimbangan kecepatan & akurasi – rekomendasi umum
- **SUP**: Akurasi tertinggi, lambat – untuk aplikasi kritis

### Ukuran Model (perkiraan):
- FAST: ~50-100 MB
- HAC: ~100-200 MB
- SUP: ~200-400 MB

## Windows

### 1. Instal Dorado (pre-built)
```powershell
# Buat folder
mkdir C:\dorado
cd C:\dorado

# Unduh rilis Windows (ganti URL dengan rilis terbaru)
Invoke-WebRequest -Uri https://cdn.oxfordnanoportal.com/software/analysis/dorado-0.x.x-win64.zip -OutFile dorado.zip
Expand-Archive dorado.zip -DestinationPath .
# Hasil: dorado.exe dengan fitur download model
```

### 2. Verifikasi
```powershell
C:\dorado\dorado.exe --version
nvidia-smi
```

### 3. Set kebijakan eksekusi (one-time)
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 4. Sesuaikan skrip
Edit baris-baris berikut di `long_run_dorado.ps1`:
```powershell
$MODEL_PATH = "C:\dorado\models\dna_r10.4.1_e8.2_400bps_hac@v5.2.0"  # path model (sesuaikan)
$INPUT_DIR  = "D:\pod5_pass"                                         # POD5 Anda
$DORADO_EXE = "C:\dorado\dorado.exe"                                 # path exe
$OUTPUT     = "D:\dorado-out"                                        # output
$DAYS       = 7                                                       # durasi hari
```

### 5. Jalankan
```powershell
powershell -File long_run_dorado.ps1
```
Terminal akan menampilkan timestamp tiap batch selesai dan lokasi file `.bam` / log GPU.

## Ubuntu

### 1. Instal Dorado (pre-built)
```bash
sudo apt update && sudo apt install -y wget unzip build-essential
mkdir -p ~/dorado && cd ~/dorado
# ganti URL dengan rilis Linux terbaru
wget https://cdn.oxfordnanoportal.com/software/analysis/dorado-0.x.x-linux-x64.zip
unzip dorado-0.x.x-linux-x64.zip
chmod +x dorado/bin/dorado
# Hasil: dorado dengan fitur download model
```

### 2. Verifikasi
```bash
~/dorado/bin/dorado --version
nvidia-smi
```

### 3. Gunakan Script Bash (Tersedia ✓)
Script bash `long_run_dorado.sh` sudah tersedia dengan fitur lengkap:

```bash
# Download dan jadikan executable
chmod +x long_run_dorado.sh

# Edit konfigurasi
nano long_run_dorado.sh
# Ganti path: MODEL_PATH, INPUT_DIR, DORADO_EXE, OUTPUT, DAYS

# Jalankan
./long_run_dorado.sh
```

**Fitur script bash:**
- ✅ Logging berwarna (info/warn/success)
- ✅ Validasi direktori & executable
- ✅ Cleanup otomatis background processes
- ✅ Error handling & status codes
- ✅ GPU monitoring dengan nvidia-smi
- ✅ Timestamp unik per batch

### 4. Alternatif: PowerShell Core di Linux
Jika ingin tetap menggunakan PowerShell:
```bash
sudo apt install -y powershell  # atau snap install powershell-core
pwsh long_run_dorado.ps1
```

## Konfigurasi Script

### PowerShell (Windows)
```powershell
$MODEL_PATH = "C:\dorado\models\dna_r10.4.1_e8.2_400bps_hac@v5.2.0"  # Path model (hasil download)
$INPUT_DIR  = "D:\pod5_pass"                                         # Folder POD5 input
$DORADO_EXE = "C:\dorado\dorado.exe"                                 # Executable Dorado
$OUTPUT     = "D:\output-dorado"                                     # Folder output
$DAYS       = 7                                                        # Durasi (hari)
```

### Bash (Ubuntu/Linux)
```bash
MODEL_PATH="$HOME/dorado/models/dna_r10.4.1_e8.2_400bps_hac@v5.2.0"  # Path model (hasil download)
INPUT_DIR="/path/to/pod5_pass"                                        # Folder POD5 input
DORADO_EXE="$HOME/dorado/bin/dorado"                                  # Executable Dorado
OUTPUT="/path/to/output-dorado"                                      # Folder output
DAYS=7                                                                  # Durasi (hari)
```

## Struktur Output

Setelah script berjalan, Anda akan mendapatkan:

```
output-dorado/
├── calls_20240331_143022.bam      # Hasil basecalling
├── dorado_20240331_143022.log     # Log Dorado
├── gpu_stats_20240331_143022.csv  # Statistik GPU
├── calls_20240331_143527.bam      # Batch berikutnya
├── dorado_20240331_143527.log
├── gpu_stats_20240331_143527.csv
└── ... (terus bertambah setiap batch)
```

**Format file CSV GPU:**
```csv
timestamp, name, temperature.gpu, utilization.gpu [%], utilization.memory [%], power.draw [W]
2024/03/31 14:30:22.123, NVIDIA RTX 4090, 65, 85, 45, 250.5
```

## Troubleshooting

### Windows
- **ExecutionPolicy error**: Jalankan `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- **Dorado not found**: Pastikan path `$DORADO_EXE` benar
- **GPU not detected**: Update driver NVIDIA, cek `nvidia-smi`

### Ubuntu/Linux
- **Permission denied**: Jalankan `chmod +x long_run_dorado.sh`
- **Dorado not found**: Pastikan path `DORADO_EXE` benar
- **GPU monitoring error**: Install NVIDIA drivers, cek `nvidia-smi`
- **Process still running**: Gunakan `ps aux | grep nvidia-smi` untuk cek background process

## Tips Optimalisasi

1. **Model Selection**: Gunakan model HAC untuk akurasi tinggi, FAST untuk kecepatan
2. **Batch Size**: Sesuaikan dengan kapasitas GPU (monitor memori)
3. **Storage**: Pastikan space mencukupi (BAM files bisa besar)
4. **Monitoring**: Gunakan `nvidia-smi` untuk cek utilisasi GPU
5. **Log Rotation**: Script otomatis membuat file baru per batch