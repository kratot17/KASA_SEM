import re

with open("latex/main.tex", "r") as f:
    text = f.read()

# 1. Update the introduction to performance comparison
old_intro = r"V~této sekci uvádíme detailní srovnání výkonnosti pouze pro sekvenci \textit{crowd\_run}. Tato sekvence byla vybrána jelikož vykazuje nejvyšší prostorovou entropii a~je pro kodéry nejnáročnější."
new_intro = r"V~této sekci uvádíme detailní srovnání výkonnosti pouze pro sekvenci \textit{old\_town\_cross}. Tato sekvence byla vybrána, jelikož se na základě R-D křivek ukázala jako nejnáročnější pro kódování (křivky dlouhodobě nedosahují hodnoty 100 jako u~ostatních videí)."
text = text.replace(old_intro, new_intro)

# 2. Swap Table 2 (Main) and Table 4 (Appendix)
# Table 2 current
table2_old = r"""\begin{table}[H]
\centering
\caption{Srovnání výkonnosti kodérů pro vysokou kvalitu obrazu (vstup: 500 snímků, 1080p50, sekvence crowd\_run). Kompletní tabulky pro ostatní sekvence jsou v~Příloze \ref{sec:appendix}.}
\label{tab:times}
\begin{tabular}{|l|c|r|r|r|c|}
\hline
\textbf{Kodér} & \textbf{\hyperref[sec:derived_metrics]{FPS}} & \textbf{Čas [s]} & \textbf{Původní [MB]} & \textbf{Komprim. [MB]} & \textbf{Úspora} \\
\hline
hevc\_videotoolbox (HW) & 166,67 & 3 & 1555,20 & 182,31 & 88,28\ \% \\
libx264 (CPU) & 62,50 & 8 & 1555,20 & 35,13 & 97,74\ \% \\
libx265 (CPU) & 25,00 & 20 & 1555,20 & 42,28 & 97,28\ \% \\
libsvtav1 (CPU) & 41,67 & 12 & 1555,20 & 110,49 & 92,90\ \% \\
libvpx-vp9 (CPU) & 4,81 & 104 & 1555,20 & 126,70 & 91,85\ \% \\
\hline
\end{tabular}
\end{table}"""

table2_new = r"""\begin{table}[H]
\centering
\caption{Srovnání výkonnosti kodérů pro vysokou kvalitu obrazu (vstup: 500 snímků, 1080p50, sekvence old\_town\_cross). Kompletní tabulky pro ostatní sekvence jsou v~Příloze \ref{sec:appendix}.}
\label{tab:times}
\begin{tabular}{|l|c|r|r|r|c|}
\hline
\textbf{Kodér} & \textbf{\hyperref[sec:derived_metrics]{FPS}} & \textbf{Čas [s]} & \textbf{Původní [MB]} & \textbf{Komprim. [MB]} & \textbf{Úspora} \\
\hline
hevc\_videotoolbox (HW) & 166,67 & 3 & 1555,20 & 145,33 & 90,66\ \% \\
libx264 (CPU) & 83,33 & 6 & 1555,20 & 11,11 & 99,29\ \% \\
libx265 (CPU) & 45,45 & 11 & 1555,20 & 11,75 & 99,24\ \% \\
libsvtav1 (CPU) & 50,00 & 10 & 1555,20 & 43,51 & 97,20\ \% \\
libvpx-vp9 (CPU) & 4,10 & 122 & 1555,20 & 92,71 & 94,04\ \% \\
\hline
\end{tabular}
\end{table}"""

# Table 4 (Appendix) current
table4_old = r"""\begin{table}[H]
\centering
\caption{Srovnání výkonnosti kodérů (vstup: 500 snímků, 1080p50, sekvence old\_town\_cross).}
\begin{tabular}{|l|c|r|r|r|c|}
\hline
\textbf{Kodér} & \textbf{\hyperref[sec:derived_metrics]{FPS}} & \textbf{Čas [s]} & \textbf{Původní [MB]} & \textbf{Komprim. [MB]} & \textbf{Úspora} \\
\hline
hevc\_videotoolbox (HW) & 166,67 & 3 & 1555,20 & 145,33 & 90,66\ \% \\
libx264 (CPU) & 83,33 & 6 & 1555,20 & 11,11 & 99,29\ \% \\
libx265 (CPU) & 45,45 & 11 & 1555,20 & 11,75 & 99,24\ \% \\
libsvtav1 (CPU) & 50,00 & 10 & 1555,20 & 43,51 & 97,20\ \% \\
libvpx-vp9 (CPU) & 4,10 & 122 & 1555,20 & 92,71 & 94,04\ \% \\
\hline
\end{tabular}
\end{table}"""

table4_new = r"""\begin{table}[H]
\centering
\caption{Srovnání výkonnosti kodérů (vstup: 500 snímků, 1080p50, sekvence crowd\_run).}
\begin{tabular}{|l|c|r|r|r|c|}
\hline
\textbf{Kodér} & \textbf{\hyperref[sec:derived_metrics]{FPS}} & \textbf{Čas [s]} & \textbf{Původní [MB]} & \textbf{Komprim. [MB]} & \textbf{Úspora} \\
\hline
hevc\_videotoolbox (HW) & 166,67 & 3 & 1555,20 & 182,31 & 88,28\ \% \\
libx264 (CPU) & 62,50 & 8 & 1555,20 & 35,13 & 97,74\ \% \\
libx265 (CPU) & 25,00 & 20 & 1555,20 & 42,28 & 97,28\ \% \\
libsvtav1 (CPU) & 41,67 & 12 & 1555,20 & 110,49 & 92,90\ \% \\
libvpx-vp9 (CPU) & 4,81 & 104 & 1555,20 & 126,70 & 91,85\ \% \\
\hline
\end{tabular}
\end{table}"""

text = text.replace(table2_old, table2_new)
text = text.replace(table4_old, table4_new)

# 3. Swap Table 3 (Medium quality)
table3_old = r"""\begin{table}[H]
\centering
\caption{Srovnání výkonnosti kodérů pro střední kvalitu (vstup: 500 snímků, 1080p50, sekvence crowd\_run, CRF 34 / Q 66).}
\label{tab:times_medium}
\begin{tabular}{|l|c|r|c|c|}
\hline
\textbf{Kodér} & \textbf{\hyperref[sec:derived_metrics]{FPS}} & \textbf{Čas [s]} & \textbf{Komprim. [MB]} & \textbf{Průměrné VMAF} \\
\hline
hevc\_videotoolbox (HW) & 166,67 & 3 & 76,38 & 99,87 \\
libx264 (CPU) & 100,00 & 5 & 6,74 & 59,91 \\
libx265 (CPU) & 50,00 & 10 & 7,00 & 63,55 \\
libsvtav1 (CPU) & 45,45 & 11 & 42,41 & 98,67 \\
libvpx-vp9 (CPU) & 7,35 & 68 & 49,97 & 98,66 \\
\hline
\end{tabular}
\end{table}"""

table3_new = r"""\begin{table}[H]
\centering
\caption{Srovnání výkonnosti kodérů pro střední kvalitu (vstup: 500 snímků, 1080p50, sekvence old\_town\_cross, CRF 34 / Q 66).}
\label{tab:times_medium}
\begin{tabular}{|l|c|r|c|c|}
\hline
\textbf{Kodér} & \textbf{\hyperref[sec:derived_metrics]{FPS}} & \textbf{Čas [s]} & \textbf{Komprim. [MB]} & \textbf{Průměrné VMAF} \\
\hline
hevc\_videotoolbox (HW) & 166,67 & 3 & 26,23 & 94,19 \\
libx264 (CPU) & 166,67 & 3 & 1,34 & 68,05 \\
libx265 (CPU) & 83,33 & 6 & 0,81 & 71,37 \\
libsvtav1 (CPU) & 83,33 & 6 & 3,41 & 95,37 \\
libvpx-vp9 (CPU) & 9,26 & 54 & 11,60 & 92,97 \\
\hline
\end{tabular}
\end{table}"""

text = text.replace(table3_old, table3_new)

# 4. Text around RD curves
rd_text_old = r"""Na Obrázku \ref{fig:rd_vmaf_crowd} je vidět aplikace metriky \hyperref[sec:metrics]{VMAF} na pohybově složitou sekvenci. Potvrzuje se efektivita nejnovějšího standardu \hyperref[sec:standards]{AV1} (\texttt{libsvtav1}). Hardwarový kodér je v~této grafické reprezentaci výrazně posunut vpravo; vyžaduje přibližně čtyřnásobný objem dat k~udržení stejného \hyperref[sec:metrics]{VMAF} skóre jako \texttt{libx265}. 

\begin{figure}[H]
    \centering
    \includegraphics[width=0.8\textwidth]{rd_vmaf_crowd_run_1080p50.pdf}
    \caption{R-D Křivka (\hyperref[sec:metrics]{VMAF}) pro sekvenci crowd\_run\_1080p50.}
    \label{fig:rd_vmaf_crowd}
\end{figure}"""

rd_text_new = r"""Na Obrázku \ref{fig:rd_vmaf_old_town} je vidět aplikace metriky \hyperref[sec:metrics]{VMAF} na pohybově nejsložitější sekvenci. Potvrzuje se efektivita nejnovějšího standardu \hyperref[sec:standards]{AV1} (\texttt{libsvtav1}). Dále je zde velmi zřetelný problém sekvence \textit{old\_town\_cross}, kdy křivky pro kodéry (jako například VP9 a~hardwarový HEVC) ani při vysokých datových tocích nedosahují ideální hranice VMAF 100.

\begin{figure}[H]
    \centering
    \includegraphics[width=0.8\textwidth]{rd_vmaf_old_town_cross_1080p50.pdf}
    \caption{R-D Křivka (\hyperref[sec:metrics]{VMAF}) pro sekvenci old\_town\_cross\_1080p50.}
    \label{fig:rd_vmaf_old_town}
\end{figure}"""

text = text.replace(rd_text_old, rd_text_new)

# 5. Text spatial complexity
spatial_old = r"""Z~naměřených výsledků vyplývá přímá úměra mezi prostorovou složitostí (entropií) a~kompresní náročností. Sekvence \textit{crowd\_run}, vykazující nejvyšší entropii (7,45 bit/px), vyžaduje pro dosažení \hyperref[sec:metrics]{VMAF} skóre 95 u~kodéru \texttt{libx265} o~42 \% vyšší datový tok než sekvence \textit{park\_joy} s~nižší entropií (6,97 bit/px). Tímto se experimentálně potvrzuje teoretický předpoklad o~vlivu prostorové redundance (\textit{Spatial Redundancy}) na efektivitu komprese."""
spatial_new = r"""Z~naměřených výsledků vyplývá, že kompresní náročnost nezávisí pouze na prostorové složitosti (entropii), ale také na složitosti pohybu. Sekvence \textit{old\_town\_cross}, přestože nevykazuje absolutně nejvyšší entropii (7,11 bit/px), se ukázala jako nejnáročnější pro kódování. Jak je vidět na chování kodérů, ani při maximální analyzované kvalitě křivky pro některé kodéry nedosahují hranice 100 VMAF. Výsledná náročnost je tedy kombinací jak prostorové redundance, tak časové (pohybové) složitosti scény."""
text = text.replace(spatial_old, spatial_new)

# 6. Temporal VMAF figure main text
temp_vmaf_old = r"""\begin{figure}[H]
    \centering
    \includegraphics[width=0.85\textwidth]{per_frame_vmaf_crowd_run_1080p50.pdf}
    \caption{Časový průběh \hyperref[sec:metrics]{VMAF} pro sekvenci crowd\_run (střední kvalita).}
    \label{fig:temporal_vmaf}
\end{figure}"""

temp_vmaf_new = r"""\begin{figure}[H]
    \centering
    \includegraphics[width=0.85\textwidth]{per_frame_vmaf_old_town_cross_1080p50.pdf}
    \caption{Časový průběh \hyperref[sec:metrics]{VMAF} pro sekvenci old\_town\_cross (střední kvalita).}
    \label{fig:temporal_vmaf}
\end{figure}"""

text = text.replace(temp_vmaf_old, temp_vmaf_new)

# 7. Appendix RD VMAF swap
appendix_rd_old = r"""\begin{figure}[H]
    \centering
    \includegraphics[width=0.75\textwidth]{rd_vmaf_old_town_cross_1080p50.pdf}
    \caption{R-D Křivka (\hyperref[sec:metrics]{VMAF}) pro sekvenci old\_town\_cross\_1080p50.}
\end{figure}"""

appendix_rd_new = r"""\begin{figure}[H]
    \centering
    \includegraphics[width=0.75\textwidth]{rd_vmaf_crowd_run_1080p50.pdf}
    \caption{R-D Křivka (\hyperref[sec:metrics]{VMAF}) pro sekvenci crowd\_run\_1080p50.}
\end{figure}"""

text = text.replace(appendix_rd_old, appendix_rd_new)

# 8. Appendix temporal VMAF swap
appendix_temp_old = r"""\begin{figure}[H]
    \centering
    \includegraphics[width=0.85\textwidth]{per_frame_vmaf_old_town_cross_1080p50.pdf}
    \caption{Časový průběh \hyperref[sec:metrics]{VMAF}: old\_town\_cross\_1080p50.}
\end{figure}"""

appendix_temp_new = r"""\begin{figure}[H]
    \centering
    \includegraphics[width=0.85\textwidth]{per_frame_vmaf_crowd_run_1080p50.pdf}
    \caption{Časový průběh \hyperref[sec:metrics]{VMAF}: crowd\_run\_1080p50.}
\end{figure}"""

text = text.replace(appendix_temp_old, appendix_temp_new)

with open("latex/main.tex", "w") as f:
    f.write(text)

print("Done")
