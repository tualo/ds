delimiter //

CREATE OR REPLACE FUNCTION `getRequestParameterInteger`( fieldName varchar(255) )
RETURNS INTEGER
BEGIN 
    IF @request_parameter is not null THEN
        
        IF JSON_VALID(@request_parameter) = 1 THEN
            IF JSON_TYPE(json_extract(@request_parameter,concat('$.',fieldName)))='INTEGER' THEN
              return json_value(@request_parameter,concat('$.',fieldName));
            END IF;
        END IF;
    END IF;
    return null;
END //


CREATE OR REPLACE FUNCTION `getRequestParameterDouble`( fieldName varchar(255) )
RETURNS DECIMAL(15,5)
BEGIN 
    IF @request_parameter is not null THEN
        
        IF JSON_VALID(@request_parameter) = 1 THEN
            IF JSON_TYPE(json_extract(@request_parameter,concat('$.',fieldName)))='DOUBLE' THEN
              return json_value(@request_parameter,concat('$.',fieldName));
            END IF;
        END IF;
    END IF;
    return null;
END //

CREATE OR REPLACE FUNCTION `getRequestParameterDate`( fieldName varchar(255) )
RETURNS DATE
BEGIN 
    IF @request_parameter is not null THEN
        IF JSON_VALID(@request_parameter) = 1 THEN
            IF JSON_TYPE(json_extract(@request_parameter,concat('$.',fieldName)))='STRING' THEN
              return cast(json_value(@request_parameter,concat('$.',fieldName)) as date);
            END IF;
        END IF;
    END IF;

    return null;

END //



CREATE OR REPLACE FUNCTION `getRequestParameterString`( fieldName varchar(255) )
RETURNS VARCHAR(255)
BEGIN 
    IF @request_parameter is not null THEN
        IF JSON_VALID(@request_parameter) = 1 THEN
            IF JSON_TYPE(json_extract(@request_parameter,concat('$.',fieldName)))='STRING' THEN
              return json_value(@request_parameter,concat('$.',fieldName));
            END IF;
        END IF;
    END IF;

    return null;

END //


CREATE OR REPLACE FUNCTION `getRequestParameterBoolean`( fieldName varchar(255) )
RETURNS BOOLEAN
BEGIN 
    IF @request_parameter is not null THEN
        IF JSON_VALID(@request_parameter) = 1 THEN
            IF JSON_TYPE(json_extract(@request_parameter,concat('$.',fieldName)))='BOOLEAN' THEN
              return json_value(@request_parameter,concat('$.',fieldName));
            END IF;
        END IF;
    END IF;

    return null;

END //