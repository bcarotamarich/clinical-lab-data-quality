-- ================================================
-- CLINICAL LAB DATA QUALITY CHECKS
-- Author: Bianca Carota Marich
-- Description: SQL queries to detect anomalies,
-- out-of-range results and data quality issues
-- ================================================

-- 1. ALL FAILED RESULTS (out of reference range)
SELECT sample_id, patient_id, date, parameter, result, unit,
       reference_min, reference_max, observations
FROM lab_results
WHERE qc_status = 'FAIL'
ORDER BY date;

-- 2. COUNT OF FAILS BY PARAMETER
SELECT parameter,
       COUNT(*) AS total_fails
FROM lab_results
WHERE qc_status = 'FAIL'
GROUP BY parameter
ORDER BY total_fails DESC;

-- 3. CRITICAL VALUES (far from reference range)
SELECT sample_id, patient_id, date, parameter, result, unit, observations
FROM lab_results
WHERE (result < reference_min * 0.5)
   OR (result > reference_max * 2)
ORDER BY date;

-- 4. DAILY QC SUMMARY
SELECT date,
       COUNT(*) AS total_samples,
       SUM(CASE WHEN qc_status = 'PASS' THEN 1 ELSE 0 END) AS passed,
       SUM(CASE WHEN qc_status = 'FAIL' THEN 1 ELSE 0 END) AS failed,
       ROUND(100.0 * SUM(CASE WHEN qc_status = 'FAIL' THEN 1 ELSE 0 END) / COUNT(*), 1) AS fail_rate_pct
FROM lab_results
GROUP BY date
ORDER BY date;

-- 5. SAMPLES WITHOUT OBSERVATIONS (missing documentation)
SELECT sample_id, patient_id, date, parameter, qc_status
FROM lab_results
WHERE qc_status = 'FAIL'
  AND (observations IS NULL OR observations = '')
ORDER BY date;

-- 6. FAIL RATE BY TEST TYPE
SELECT test_type,
       COUNT(*) AS total,
       SUM(CASE WHEN qc_status = 'FAIL' THEN 1 ELSE 0 END) AS fails,
       ROUND(100.0 * SUM(CASE WHEN qc_status = 'FAIL' THEN 1 ELSE 0 END) / COUNT(*), 1) AS fail_pct
FROM lab_results
GROUP BY test_type;
