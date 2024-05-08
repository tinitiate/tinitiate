CREATE OR REPLACE PROCEDURE process_data(as_of_date DATE, input_string VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Variables to hold intermediate data
    pair_array VARCHAR[];
    pair_element VARCHAR;
    elem_array VARCHAR[];
BEGIN
    -- Split the input string into an array of "relationship_no|entity_no" pairs
    pair_array := string_to_array(input_string, ',');

    -- Temporary table to hold the extracted values
    CREATE TEMP TABLE IF NOT EXISTS temp_relationship_entity (
        relationship_no VARCHAR,
        entity_no VARCHAR
    );

    -- Clear the temporary table to handle repeated calls
    TRUNCATE temp_relationship_entity;

    -- Loop through each pair and split into relationship_no and entity_no
    FOREACH pair_element IN ARRAY pair_array LOOP
        elem_array := string_to_array(pair_element, '|'); -- Split the pair by '|'
        -- Insert split values into the temporary table
        INSERT INTO temp_relationship_entity (relationship_no, entity_no)
        VALUES (elem_array[1], elem_array[2]);
    END LOOP;

    -- Example usage with a WITH clause to manipulate or query the data
    WITH RECURSIVE data_cte AS (
        SELECT relationship_no, entity_no
        FROM temp_relationship_entity
    )
    SELECT * FROM data_cte;

END;
$$;
