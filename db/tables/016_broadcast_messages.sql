CREATE TABLE broadcast_messages(
	
	id INT NOT NULL IDENTITY(1,1),
	sent_by_user_id INT NOT NULL ,
	title NVARCHAR(100) NOT NULL ,
	message NVARCHAR(500) NOT NULL ,
	sent_at DATETIME2(0) NOT NULL CONSTRAINT DF_broadcast_messages_sent_at DEFAULT CURRENT_TIMESTAMP,

	CONSTRAINT PK_broadcast_messages_id PRIMARY KEY (id),
	
	CONSTRAINT FK_broadcast_messages_users_sent_by_user_id FOREIGN KEY (sent_by_user_id) REFERENCES users(id) ON DELETE NO ACTION
																											  ON UPDATE CASCADE ,
																											  

	CONSTRAINT CK_broadcast_messages_title CHECK (LEN(LTRIM(RTRIM(title)))>=5 AND LEN(LTRIM(RTRIM(title)))<=100),
	CONSTRAINT CK_broadcast_messages_message  CHECK (LEN(LTRIM(RTRIM(message)))>=10 AND LEN(LTRIM(RTRIM(message)))<=500)

)