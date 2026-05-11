# Analýza vlastností kodéru HEVC a moderních alternativ

Tento repozitář obsahuje semestrální projekt pro předmět **B(E)2M37KASA (Komprese obrazu a signálů)** na ČVUT FEL. Projekt se zabývá experimentální analýzou a srovnáním efektivity moderních standardů pro kompresi videa (H.264, H.265/HEVC, VP9, AV1) včetně vlivu hardwarové akcelerace (Apple Silicon).

## 📄 Struktura repozitáře

*   **`latex/`** - Zdrojové kódy k protokolu (LaTeX) a vygenerované výsledné PDF (`main.pdf`).
*   **`scripts/`** - Automatizační skripty:
    *   Bash skripty pro dávkové kódování (`encode_videos.sh`) a výpočet metrik pomocí FFmpeg (`calculate_metrics.sh`).
    *   MATLAB skripty pro analýzu entropie a automatické vykreslování R-D křivek (`plot_rd_curves.m`).
*   **`results/`** - Agregovaná data a výsledky měření ve formátu CSV.
*   **`logs/`** - Surové logy z výpočtů metrik (PSNR, SSIM, VMAF) pro jednotlivé snímky.

## 💾 Externí úložiště objemných dat (Google Drive)

Z důvodu enormní velikosti (desítky GB) **nejsou** v tomto repozitáři uložena nekomprimovaná referenční videa ani samotné překódované výstupy.

Tyto složky (`raw_videos/` a `encoded_videos/`) jsou veřejně dostupné na **Google Drive**:
🔗 **[Odkaz na Google Drive úložiště](https://drive.google.com/drive/folders/1dQosNQVMNARsGfBLjNj08zZU0Cm_nrx5?usp=sharing)**

Pro spuštění a reprodukci experimentů u vás lokálně si prosím stáhněte obsah výše uvedeného odkazu a složky vložte do kořenového adresáře tohoto projektu.
