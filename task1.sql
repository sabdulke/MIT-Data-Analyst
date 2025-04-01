SET search_path = analyst;

-- (A) Write a query that retrieves registrants whose total lobbying spend exceeds $10,000,000 (we call these
-- "super-registrants"); your query should return all relevant cases, but your document output can be
-- limited to the top 10.

-- Retrieve registrant name and calculate total lobbying spend
SELECT
    registrant_name, SUM(amount) total_amount

FROM
    -- Join with registrant dollar amount data
    registrants
    JOIN filings USING (registrant_id)

GROUP BY
    registrant_name,
    registrant_id

--Total lobby spending must exceed $10,000,000
HAVING SUM(amount::NUMERIC) > 10000000

--Sort total lobbying send in descending order
ORDER BY
    SUM(amount) DESC NULLS LAST

--Limit output to the top 10 registrants
LIMIT
    10;

-- _____________________________________________________________________________________________________________
-- (B) Select the five biggest registrants by dollar amount, and for each registrant, select their five biggest
-- clients (each) by dollar amount in descending order; if any registrant has fewer than five, you may just
-- list their clients.

-- Retrieve registrants, their clients, and client's total amount of lobbying spending
SELECT
    registrant_name,
    client_name,
    total_amount
FROM (

--     Select the five biggest clients from each of the biggest registrants
    SELECT registrant_id,
           client_name,
           client_id,
           SUM(amount) total_amount,

           -- Sort the clients in descending order by dollar amount and mark row with number of occurrence, alias clientPerRegistrant
           ROW_NUMBER() OVER (PARTITION BY
               registrant_id ORDER BY SUM(amount) DESC NULLS LAST) clientPerRegistrant

           -- Join with dollar amount data from filings table
          FROM clients
                  JOIN filings USING (client_id)

           -- Clients must only be from the top 5 registrants
          WHERE registrant_id in
                    (

                  --     Select the five biggest registrants by dollar amount
                  SELECT registrant_id
                  FROM registrants
                           JOIN filings USING (registrant_id)
                  GROUP BY registrant_name,
                           registrant_id
                  ORDER BY SUM(amount) DESC NULLS LAST

                  -- Limit to the top 5 registrants
                  LIMIT 5)


          GROUP BY registrant_id,
                   client_name,
                   client_id

          ) registrantsClients

    -- Join with registrant name data from registrants table
    JOIN registrants using (registrant_id)

--Limit to first 5 occurrences of client for each registrant
WHERE clientPerRegistrant <= 5
GROUP BY registrant_name, client_name, total_amount

--Sort in descending order
ORDER BY registrant_name DESC, total_amount DESC;

-- _____________________________________________________________________________________________________________
-- (C) Among all registrants, identify the registrant who has lobbied the most separate bills in the Medi-
-- care/Medicaid issue category. You can identify Medicare/Medicaid lobbying through the issue code
-- MMM. Write a query that returns the unique bill IDs that the registrant has lobbied; your query should
-- return all bill IDs, but your document output can be limited to a sample of 10.

SELECT
   bill_id

    FROM
        filings_bills
        JOIN
--         Retrieve the registrant who has lobbied the most separate bills as well as their respective filing_uuids
        (SELECT filing_uuid

            FROM
                filings
                JOIN
                    -- Retrieve the filing uuids for the Medicare/Medicaid issue category
                        (SELECT
                            filing_uuid
                        FROM
                            filings_issues
                        WHERE
                            general_issue_code = 'MMM')
                        AS all_mmm_uuids USING (filing_uuid)

            GROUP BY registrant_id, filing_uuid
            ORDER BY count(*) OVER (partition by registrant_id) DESC
            FETCH FIRST 1 ROWS WITH TIES) as registrant_filing_uuids USING (filing_uuid);

-- _____________________________________________________________________________________________________________
-- (D) Most bills in the U.S. Congress have a title format that ends in "Act", "Law", or "Resolution". Call these
-- bills "standard titles". Write a query that counts how many bills in the ‘bills‘ table have "standard"
-- titles and how many bills have "non-standard titles". Provide only the totals for each.

SELECT
    count, bill_titles
FROM
    (SELECT COUNT(title) count, 'standard titles' bill_titles  FROM bills WHERE title SIMILAR TO ('%Act|%Law|%Resolution')) as standard
    UNION ALL
    (SELECT COUNT(title) count,  'non-standard titles' bill_titles FROM bills WHERE title NOT SIMILAR TO ('%Act|%Law|%Resolution'));


