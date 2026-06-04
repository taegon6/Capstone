# Public CSI Dataset References

This project can run with live ESP32-S3 logs, mock data, and small public CSI subsets.

## HomeHAR
- Source: https://huggingface.co/datasets/gadgadgad/HomeHAR
- License: CC BY 4.0
- Hardware: 2 ESP32-C6 boards operating as commodity 802.11n access points
- Classes: `drink`, `eat`, `empty`, `sleep`, `smoke`, `watch`, `work`
- Format: CSV rows with `CSI_DATA` metadata and a final `data` column containing 128 signed integers representing 64 I/Q CSI values
- Use in this project: download small class subsets for proof-of-pipeline analysis, not as a claim that our ESP32-S3 setup produced those labels

## Dataset for HAR Using Wi-Fi CSI
- Source: https://figshare.com/articles/dataset/Dataset_for_Human_Activity_Recognition_using_Wi-Fi_Channel_State_Information_CSI_data/14386892
- License: CC BY 4.0
- Activities include walking, sitting, standing, lying, getting up, getting down, and no activity
- Total size is about 489 MB, so it is better suited for offline report experiments than quick capstone demos

## SHD-HAR Dataset
- Source: https://zenodo.org/records/11201414
- Related article describes ESP32-S3 CSI collection with multiple transceiver paths and 10 movements
- Use as a reference for future dataset expansion and benchmark-style experiments

