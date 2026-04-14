# Logistics-Membership-Analysis
End-to-End SQL + Tableau project for cleaning and analyzing membership data to generate business insights.
# 📊 International Logistics Association Membership Analysis

## 🏷️ Project Title
International Logistics Association Membership Dashboard

---

## 🧾 Brief One Line Summary
End-to-end SQL and Tableau project transforming raw membership data into actionable business insights.

---

## 🔍 Overview
This project focuses on cleaning, transforming, and analyzing membership data for an international logistics association. 

Using PostgreSQL, I performed data cleaning and validation, followed by building an interactive Tableau dashboard to track key business metrics such as revenue, member status, and certification trends.

---

## ❗ Problem Statement
The raw dataset contained multiple data quality issues:
- Inconsistent member IDs
- Currency values stored as text with symbols
- Mixed date formats
- Duplicate records
- Missing certification values

These issues made the data unreliable for analysis and decision-making.

---

## 📂 Dataset
- Source: Membership dataset (CSV format)
- Contains:
  - Member details (ID, Name, Address)
  - Membership type
  - Dues amount (Revenue)
  - Membership validity dates
  - Certification details

---

## 🛠️ Tools and Technologies
- **PostgreSQL:** Data cleaning, transformation, and analysis
- **SQL:** Regex, CTEs, Window Functions
- **Tableau:** Dashboard creation and visualization
- **CSV/Excel:** Raw data handling

---

## ⚙️ Methods

### Data Cleaning & Transformation
- Validated Member IDs using Regex
- Converted dues amount from text (`$`, `,`) to numeric
- Standardized date formats using `TO_DATE`
- Merged multiple address columns into one
- Replaced NULL certifications with `"No Certification"`

### Data Preparation
- Removed duplicate records using `ROW_NUMBER()`
- Eliminated invalid records (NULL IDs)
- Applied Primary Key constraint for data integrity

### Analysis Techniques
- Revenue aggregation by membership type
- Member status classification (Active vs Expired)
- Certification distribution analysis
- Ranking top-paying members using Window Functions

---

## 📊 Key Insights
- **Professional Members** generate the highest revenue
- A large number of members are **expired**, indicating retention opportunities
- Most members do not have certifications → potential growth area
- Revenue distribution is uneven across membership types

---

## 📈 Dashboard / Model Output
The Tableau dashboard provides:
- Total Members KPI
- Total Revenue KPI
- Revenue by Membership Type
- Member Status (Active vs Expired)
- Expiry Trends over time
- Certification Distribution

📸 Dashboard Preview:
![Dashboard](<img width="1280" height="1024" alt="mbd tableau ss" src="https://github.com/user-attachments/assets/f771a51b-be42-4295-8998-3adc30078d4f" />
)

----

## 📂 Project Structure

```bash
Logistics-Membership-Analysis/
│
├── Data/
│   ├── raw_membership_data.csv
│   └── cleaned_member.csv
│
├── SQL/
│   └── membership_analysis.sql
│
├── Tableau/
│   └── membership_dashboard.twbx
│
├── Screenshots/
│   └── dashboard.png
│
└── README.md
```
---

## ▶️ How to Run this Project
1. Import the CSV file from `/Data`
2. Run SQL script from `/SQL` in PostgreSQL
3. Generate cleaned dataset
4. Open Tableau file from `/Tableau`
5. Connect to cleaned data and view dashboard

---

## 📌 Results & Conclusion
The project successfully transformed raw, inconsistent data into a structured dataset ready for business analysis.

It highlights key business opportunities:
- Improve member retention strategies
- Promote certification programs
- Focus on high-revenue membership segments

---

## 🔮 Future Work
- Automate ETL pipeline using Python
- Add predictive analysis (member churn prediction)
- Integrate real-time dashboard updates
- Enhance dashboard with filters and drill-down features

---

## 👨‍💻 Author
**Shafi Mulani**  
Aspiring Data Analyst | SQL | Tableau | Excel
