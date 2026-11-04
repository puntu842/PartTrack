-- Setting up the database schema

CREATE DATABASE IF NOT EXISTS parttrack;
USE parttrack;

CREATE TABLE user_account (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(30) NOT NULL UNIQUE,
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  phone_number VARCHAR(20),
  email VARCHAR(100),
  role ENUM('admin','technician','customer') NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE supplier (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  contact_phone VARCHAR(20),
  email VARCHAR(100),
  tax_id VARCHAR(30),
  country_code CHAR(2)
);

CREATE TABLE part (
  part_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  sku VARCHAR(20) NOT NULL UNIQUE,
  current_stock INT NOT NULL DEFAULT 0,
  reorder_point INT
);

CREATE TABLE part_supplier (
  part_id INT NOT NULL,
  supplier_id INT NOT NULL,
  unit_cost DECIMAL(10,2) NOT NULL,
  lead_time_days SMALLINT UNSIGNED,
  is_preferred BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (part_id, supplier_id),
  FOREIGN KEY (part_id) REFERENCES part(part_id),
  FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
);

CREATE TABLE vehicle (
  vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
  owner_id INT NOT NULL,
  vin CHAR(17) NOT NULL UNIQUE,
  license_plate VARCHAR(32),
  make VARCHAR(40),
  model VARCHAR(60),
  model_year SMALLINT UNSIGNED,
  trim_level VARCHAR(60),
  powertrain_type ENUM('ICE','Hybrid','EV'),
  odometer INT,
  date_registered DATE,
  FOREIGN KEY (owner_id) REFERENCES user_account(user_id)
);

CREATE TABLE job (
  job_id INT AUTO_INCREMENT PRIMARY KEY,
  vehicle_id INT NOT NULL,
  technician_id INT,
  status ENUM('Inspection','Waiting_for_parts','In_service',
              'Ready_for_pickup','Closed') NOT NULL DEFAULT 'Inspection',
  started_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  finished_time DATETIME,
  description VARCHAR(255),
  customer_complaint VARCHAR(255),
  notes VARCHAR(255),
  FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id),
  FOREIGN KEY (technician_id) REFERENCES user_account(user_id)
);

CREATE TABLE part_usage (
  usage_id INT AUTO_INCREMENT PRIMARY KEY,
  part_id INT NOT NULL,
  job_id INT NOT NULL,
  quantity INT UNSIGNED NOT NULL,
  time_of_use DATETIME NOT NULL,
  FOREIGN KEY (part_id) REFERENCES part(part_id),
  FOREIGN KEY (job_id) REFERENCES job(job_id)
);

DELIMITER //

CREATE TRIGGER trg_prevent_negative_stock
BEFORE INSERT ON part_usage
FOR EACH ROW
BEGIN
  DECLARE v_stock INT;
  SELECT current_stock INTO v_stock FROM part WHERE part_id = NEW.part_id;
  IF v_stock IS NOT NULL AND NEW.quantity > v_stock THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'not enough stock';
  END IF;
END //

CREATE PROCEDURE LogPartUsage(IN p_job INT, IN p_part INT, IN p_qty INT)
BEGIN
  DECLARE v_stock INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  SELECT current_stock INTO v_stock FROM part
   WHERE part_id = p_part FOR UPDATE;          -- locks the row: no race
  INSERT INTO part_usage (part_id, job_id, quantity, time_of_use)
  VALUES (p_part, p_job, p_qty, NOW());        -- trigger checks stock here
  UPDATE part SET current_stock = current_stock - p_qty
   WHERE part_id = p_part;
  COMMIT;
END //

DELIMITER ;

-- Show the created tables, triggers, and procedures

SHOW TABLES;
SHOW TRIGGERS;
SHOW PROCEDURE STATUS WHERE Db = 'parttrack';

-- Insert sample data

INSERT INTO part (name, sku, current_stock, reorder_point) VALUES
('Brake pad set','BP-001',10,5),
('Oil filter','OF-002',3,5);
INSERT INTO vehicle (owner_id, vin, make, model, model_year, powertrain_type) VALUES 
(1,'JTDKN3DU0A0000001','Toyota','Prius',2018,'Hybrid');
INSERT INTO job (vehicle_id, technician_id, status, description)
VALUES (
  (SELECT vehicle_id FROM vehicle WHERE vin = 'JTDKN3DU0A0000001'),
  (SELECT user_id FROM user_account WHERE username = 'tech1'),
  'In_service',
  'Brake service'
);

-- Select statements to verify the data

SELECT user_id, username, role FROM user_account;
SELECT job_id, vehicle_id, technician_id FROM job;
SELECT part_id, name FROM part;
SELECT user_id, username, role, is_active FROM user_account;