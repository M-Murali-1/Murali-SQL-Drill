-- Creating the Database for the Tables
CREATE DATABASE online_chart_system;
SHOW DATABASES;

-- Using the Created database.
USE online_chart_system;

-- Creating the Organization table
CREATE TABLE Organization (
	Id INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100)
);
DESCRIBE  Organization;

-- Creating the Channels Table.
CREATE TABLE Channel (
	Id INT AUTO_INCREMENT PRIMARY KEY ,
    Name VARCHAR(100) ,
    Parent_organization INT,
    FOREIGN KEY (Parent_organization) REFERENCES Organization(Id)
);
DESCRIBE Channel;

-- Creating the User Table.
CREATE TABLE Users (
	Id INT AUTO_INCREMENT PRIMARY KEY , 
	Name VARCHAR(100)
);
DESCRIBE Users;

-- Creating the Messages Table.
CREATE TABLE Messages ( 
	Id INT AUTO_INCREMENT PRIMARY KEY ,
    Content VARCHAR(100) ,
    Post_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    User_id INT NOT NULL ,
    Channel_id INT NOT NULL
);
DESCRIBE Messages;


-- Creating the join table for the channels subscribed by the users.
CREATE TABLE Channels_subscribed (User_id int,
 	Channel_id int,
	FOREIGN KEY (User_id) REFERENCES Users(Id),
	FOREIGN KEY (Channel_id) REFERENCES Channel(Id)  ON DELETE CASCADE
);
DESCRIBE Channels_subscribed;

-- One organization, Lambda School
INSERT INTO Organization (Name) VALUES("Lambda School");

-- Three users, Alice, Bob, and Chris
INSERT INTO Users (Name) VALUES 
("Alice"),
("Bob"),
("Chris");

-- Two channels, #general and #random
INSERT INTO Channel (Name,Parent_organization) VALUES ("#general",1),("#random",1);

-- 10 messages (at least one per user, and at least one per channel).
INSERT INTO Messages (Content,User_id,Channel_id) VALUES
("Hello, how’s everyone?", 1, 1),
("Hey, what’s new?", 2, 1),
("Good morning, team!", 3, 2),
("Can we meet today?", 1, 2),
("Looking forward to the project launch", 2, 1),
("Anyone want to join the meeting?", 3, 2),
("How was the weekend?", 1, 1),
("Let’s catch up soon", 1, 2),
("What’s the status of the report?", 2, 1),
("Ready for the next task!", 1, 1);

-- Alice should be in #general and #random.
INSERT INTO Channels_subscribed VALUES (1,1),(1,2);

-- Bob should be in #general.
INSERT INTO Channels_subscribed VALUES  (2,1);

-- Chris should be in #random.
INSERT INTO Channels_subscribed VALUES  (3,2);

-- List all organization names.
SELECT Name FROM Organization;

-- List all channel names.
SELECT Name FROM Channel;

-- List all channels in a specific organization by organization name.
SELECT Name FROM Channel 
WHERE Parent_organization IN (SELECT Id FROM Organization WHERE Name="Lambda School");

-- List all messages in a specific channel by channel name #general in order of post_time, descending. 
-- (Hint: ORDER BY. Because your INSERTs might have all taken place at the exact same time,
-- this might not return meaningful results.But humor us with the ORDER BY anyway.)
SELECT Content FROM Messages 
WHERE Channel_id IN (SELECT Id FROM Channel WHERE Name="#general");

-- List all channels to which user Alice belongs.
SELECT Name FROM Channel
WHERE id IN( SELECT Channel_id FROM Channels_subscribed
WHERE User_id IN( SELECT Id FROM Users WHERE Name="Alice"));

-- List all users that belong to channel #general.
SELECT Name FROM Users 
WHERE Id IN( SELECT User_id FROM Channels_subscribed 
WHERE Channel_id IN(SELECT Id FROM Channel WHERE Name ="#general"));

-- List all messages in all channels by user Alice.
SELECT Content Message_by_alice 
FROM Messages 
WHERE User_id = (SELECT Id FROM Users WHERE Name="Alice");

-- List all messages in #random by user Bob.
SELECT Content Message_by_bob_random 
FROM Messages 
WHERE User_id =( SELECT Id FROM Users WHERE Name="Bob" ) AND
Channel_id = (SELECT Id FROM Channel WHERE Name="#random");

-- List the count of messages across all channels per user. (Hint: COUNT, GROUP BY.)
SELECT Name "User Name" ,COUNT(Name) "Message Count" 
FROM Messages INNER JOIN Users 
ON Messages.User_id=Users.Id 
GROUP BY Name 
ORDER BY Name DESC;

-- List the count of messages per user per channel.
SELECT Users.Name,Channel.Name,COUNT(*) FROM Messages
INNER JOIN Users
ON Messages.User_id=Users.Id 
INNER JOIN Channel 
ON Messages.Channel_id=Channel.Id 
GROUP BY Users.Name,Channel.Name
ORDER BY Channel.Name,Users.Name;

-- What SQL keywords or concept would you use if you wanted to automatically
-- delete all messages by a user if that user were deleted from the user table?
-- We Will use the ON CASCADE DELETE Keyword to perform the above operation.