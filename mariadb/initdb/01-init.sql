-- Runs once on first start (empty data volume).
-- Sample table so you have something to query for testing.
CREATE TABLE IF NOT EXISTS appdb.orders (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  customer   VARCHAR(100) NOT NULL,
  amount     DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO appdb.orders (customer, amount) VALUES
  ('Sokha', 12.50), ('Dara', 99.99), ('Vanna', 45.00);
