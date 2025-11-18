-- DATABASE CREATION --
CREATE DATABASE aopdb;
USE aopdb;

-- TABLES --
-- PRODUCT TYPE --
CREATE TABLE product_type (
    product_type_cd VARCHAR(10) PRIMARY KEY,
    name VARCHAR(50)
);

-- PRODUCT --
CREATE TABLE product (
    product_cd VARCHAR(10) PRIMARY KEY,
    name VARCHAR(50),
    product_type_cd VARCHAR(10),
    date_offered DATE,
    date_retired DATE,
    FOREIGN KEY (product_type_cd) REFERENCES product_type(product_type_cd)
);

-- CUSTOMER --
CREATE TABLE customer (
    cust_id INT PRIMARY KEY,
    fed_id VARCHAR(12),
    cust_type_cd ENUM('I','B'),
    address VARCHAR(30),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(10)
);

-- INDIVIDUAL --
CREATE TABLE individual (
    cust_id INT PRIMARY KEY,
    fname VARCHAR(30),
    lname VARCHAR(30),
    birth_date DATE,
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id)
);

-- BUSINESS --
CREATE TABLE business (
    cust_id INT PRIMARY KEY,
    name VARCHAR(40),
    state_id VARCHAR(10),
    incorp_date DATE,
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id)
);

-- OFFICER --
CREATE TABLE officer (
    officer_id SMALLINT PRIMARY KEY,
    cust_id INT,
    fname VARCHAR(30),
    lname VARCHAR(30),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (cust_id) REFERENCES business(cust_id)
);

-- BRANCH --
CREATE TABLE branch (
    branch_id SMALLINT PRIMARY KEY,
    name VARCHAR(20),
    address VARCHAR(30),
    city VARCHAR(30),
    state VARCHAR(20),
    zip VARCHAR(12)
);

-- DEPARTMENT --
CREATE TABLE department (
    dept_id SMALLINT PRIMARY KEY,
    name VARCHAR(20)
);

-- EMPLOYEE --
CREATE TABLE employee (
    emp_id SMALLINT PRIMARY KEY,
    fname VARCHAR(20),
    lname VARCHAR(20),
    start_date DATE,
    end_date DATE,
    superior_emp_id SMALLINT,
    dept_id SMALLINT,
    title VARCHAR(50),
    assigned_branch_id SMALLINT,
    FOREIGN KEY (superior_emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (dept_id) REFERENCES department(dept_id),
    FOREIGN KEY (assigned_branch_id) REFERENCES branch(branch_id)
);

-- ACCOUNT --
CREATE TABLE account (
    account_id INT PRIMARY KEY,
    product_cd VARCHAR(10),
    cust_id INT,
    open_date DATE,
    close_date DATE,
    last_activity_date DATE,
    status ENUM('ACTIVE','CLOSED'),
    open_branch_id SMALLINT,
    open_emp_id SMALLINT,
    avail_balance DECIMAL(10,2),
    pending_balance DECIMAL(10,2),
    FOREIGN KEY (product_cd) REFERENCES product(product_cd),
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id),
    FOREIGN KEY (open_branch_id) REFERENCES branch(branch_id),
    FOREIGN KEY (open_emp_id) REFERENCES employee(emp_id)
);

-- TRANSACTION --
CREATE TABLE bank_transaction (
    txn_id INT PRIMARY KEY,
    txn_date DATETIME,
    account_id INT,
    txn_type_cd ENUM('DBT','CDT'),
    amount DECIMAL(10,2),
    teller_emp_id SMALLINT,
    execution_branch_id SMALLINT,
    funds_avail_date DATETIME,
    FOREIGN KEY (account_id) REFERENCES account(account_id),
    FOREIGN KEY (teller_emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (execution_branch_id) REFERENCES branch(branch_id)
);

-- INSERTS --
-- PRODUCT TYPE --
INSERT INTO product_type VALUES
('HDW', 'Arduino'),
('STW', 'Computer Vision'),
('MDW', 'Database');

-- PRODUCT --
INSERT INTO product VALUES
('HDW1', 'Microchip', 'HDW', '2021-02-01', NULL),
('STW1', 'Artificial Intelligence', 'STW', '2024-01-04', NULL);

-- CUSTOMER --
INSERT INTO customer VALUES
(1, '123456789', 'I', 'Maple Street', 'Worcester', 'MA', '01000-000'),
(2, '987654321', 'B', 'Woodrow Wilson Street', 'Framingham', 'MA', '20000-000'),
(3, '555666777', 'B', 'Fallbrook Street', 'Leominster', 'MA', '80000-000'),
(4, '888111222', 'I', 'Sunset Road', 'Boston', 'MA', '55555-000');

-- INDIVIDUAL --
INSERT INTO individual VALUES
(1, 'Juno', 'Smith', '1990-05-10'),
(4, 'Alex', 'Barnes', '1985-09-21');

-- BUSINESS --
INSERT INTO business VALUES
(2, 'BioTech', 'USA22', '2020-01-10'),
(3, 'CyberSpace', 'USA40', '2024-08-04');

-- OFFICER --
INSERT INTO officer VALUES
(1, 3, 'Bruno', 'Mercer', '2018-03-12', NULL);

-- BRANCH --
INSERT INTO branch VALUES
(10, 'Downtown', 'Beach Avenue', 'Cape Cod', 'MA', '01310-000'),
(11, 'Uptown', 'Sunday Hill Avenue', 'Salem', 'MA', '20040-000');

-- DEPARTMENT --
INSERT INTO department VALUES
(100, 'Sales'),
(200, 'Operations');

-- EMPLOYEE --
INSERT INTO employee VALUES
(1000, 'Garfield', 'Ruthford', '2010-04-01', NULL, NULL, 100, 'Programmer', 10),
(1001, 'Amelia', 'Forrester', '2015-08-15', NULL, 1000, 200, 'Engineer', 11);

-- ACCOUNT --
INSERT INTO account VALUES
(5001, 'HDW1', 1, '2021-01-10', NULL, '2024-01-10', 'ACTIVE', 10, 1000, 3500.00, 0.00),
(5002, 'STW1', 2, '2021-06-20', NULL, '2024-01-05', 'ACTIVE', 11, 1001, 1500.00, 0.00);

-- TRANSACTION --
INSERT INTO bank_transaction VALUES
(9001, '2024-05-01 10:00:00', 5001, 'DBT', 200.00, 1001, 11, '2024-05-01 10:00:00');

-- CONSULTING --
-- 1 --
SELECT DISTINCT open_emp_id
FROM account
WHERE open_emp_id IS NOT NULL;

-- 2 --
SELECT account_id, cust_id, avail_balance
FROM account
WHERE status = 'ACTIVE'
  AND avail_balance > 2500;

-- 3 --
SELECT dept_id, MIN(start_date) AS oldest_start_date
FROM employee
GROUP BY dept_id;

-- 4 --
SELECT emp_id, fname, lname
FROM employee
ORDER BY fname ASC, lname ASC;

-- 5 --
SELECT fname, lname FROM individual
UNION
SELECT fname, lname FROM employee;

-- 6 --
SELECT emp_id
FROM employee
WHERE emp_id IN (
    SELECT superior_emp_id
    FROM employee
    WHERE superior_emp_id IS NOT NULL
);

-- 7 --
SELECT DISTINCT city
FROM customer
WHERE city NOT IN (
    SELECT city
    FROM branch
);
