# Exploration SQL Data Warehouse Project

Welcome to this exploration on SQL Data Warehousing!

This project showcases a comprehensive data warehousing pipeline—from raw data ingestion to delivering business-ready datasets—designed for immediate use by analysts. It serves as a portfolio project that demonstrates industry best practices in data engineering.

## 🏗️ Data Architecture

The project adopts the Medallion Architecture framework, comprised of three layers: **Bronze**, **Silver**, and **Gold**.

![Data Architecture]
<img width="953" height="564" alt="Architecture_00_High_Level_Architecture drawio" src="https://github.com/user-attachments/assets/812963c5-70fd-49d9-b437-009bf1f5c302" />


1. **Bronze Layer**: Stores raw data ingested as-is from the source systems, sourced from CSV files into an SQL Server Database.
2. **Silver Layer**: Processes include data cleansing, standardization, and normalization to prepare data for analysis.
3. **Gold Layer**: Contains business-ready data modeled into a star schema, optimized for reporting and analytics.

## 🔄 Data Flow
<img width="851" height="471" alt="Architecture-01_Data_Flow_Diagram drawio" src="https://github.com/user-attachments/assets/7b312c23-61cc-4b97-b65b-1b8563fc498b" />

