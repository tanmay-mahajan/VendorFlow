# VendorFlow - Deployment Guide

## Quick Start

### Prerequisites

1. **Java Development Kit (JDK) 11 or higher**
   - Download: https://adoptium.net/
   - Verify: `java -version`

2. **Apache Tomcat 9.x**
   - Download: https://tomcat.apache.org/
   - Extract to: `C:\path\to\apache-tomcat-9.x`

3. **PostgreSQL Database**
   - Download: https://www.postgresql.org/download/
   - Version: 12 or higher recommended
   - Default port: 5432

4. **Git** (for cloning repository)
   - Download: https://git-scm.com/

---

## Step-by-Step Deployment

### 1. Clone Repository

```bash
# Using HTTPS
git clone https://github.com/tanmay-mahajan/VendorFlow.git
cd VendorFlow

# Or using SSH
git clone git@github.com:tanmay-mahajan/VendorFlow.git
cd VendorFlow
```

---

### 2. Set Up Database

#### Option A: Using pgAdmin (GUI)

1. Open pgAdmin
2. Connect to PostgreSQL server
3. Create new database:
   - Name: `vendorflow`
   - Owner: `postgres`
4. Right-click database → Query Tool
5. Open `vendorflow.sql` file
6. Execute the entire script

#### Option B: Using Command Line

```bash
# Connect to PostgreSQL
psql -U postgres -h localhost

# Create database
CREATE DATABASE vendorflow;

# Connect to database
\c vendorflow;

# Execute schema
\i path/to/vendorflow.sql

# Verify tables
\dt
```

---

### 3. Configure Database Connection

1. Open file: `src/util/DBConnection.java`

2. Update connection details:

```java
private static final String DB_URL  = "jdbc:postgresql://localhost:5432/vendorflow";
private static final String DB_USER = "postgres";      // Your PostgreSQL username
private static final String DB_PASS = "your_password"; // Your PostgreSQL password
```

3. Save the file

---

### 4. Compile Java Source Files

#### Option A: Using Provided Script (Windows)

1. Ensure PowerShell is available
2. Run the deployment script:

```powershell
.\run_project.ps1
```

This script will:
- Create necessary directories
- Compile all `.java` files
- Deploy to Tomcat webapps folder
- Start Tomcat server

#### Option B: Manual Compilation

1. Set up classpath:

```bash
# Windows
set CLASSPATH=C:\path\to\tomcat\lib\servlet-api.jar;C:\path\to\postgresql-42.7.3.jar;.

# Linux/Mac
export CLASSPATH=/path/to/tomcat/lib/servlet-api.jar:/path/to/postgresql-42.7.3.jar:.
```

2. Create output directory:

```bash
mkdir -p WebContent/WEB-INF/classes
```

3. Compile Java files:

```bash
# Windows
javac -d WebContent/WEB-INF/classes -cp "%CLASSPATH%" src/controller/*.java src/dao/*.java src/model/*.java src/util/*.java

# Linux/Mac
javac -d WebContent/WEB-INF/classes -cp "$CLASSPATH" src/controller/*.java src/dao/*.java src/model/*.java src/util/*.java
```

4. Verify compilation:

```bash
ls WebContent/WEB-INF/classes/controller/
# Should show: AnalyticsServlet.class CartServlet.class ... etc.
```

---

### 5. Deploy to Tomcat

#### Option A: Automatic (via Script)

The `run_project.ps1` script automatically deploys to Tomcat.

#### Option B: Manual Deployment

1. Copy web application to Tomcat:

```bash
# Copy entire WebContent folder
cp -r WebContent /path/to/tomcat/webapps/VendorFlow

# Or create WAR file
cd WebContent
jar -cvf ../VendorFlow.war *
cp ../VendorFlow.war /path/to/tomcat/webapps/
```

2. Copy compiled classes:

```bash
cp -r WebContent/WEB-INF/classes/* /path/to/tomcat/webapps/VendorFlow/WEB-INF/classes/
```

3. Copy library files:

```bash
# Ensure JARs are in WEB-INF/lib
ls WebContent/WEB-INF/lib/
# Should show: gson-2.10.1.jar postgresql-42.7.3.jar
```

---

### 6. Configure Tomcat (if needed)

1. Set environment variables:

```bash
# Windows
set CATALINA_HOME=C:\path\to\apache-tomcat-9.x
set JAVA_HOME=C:\path\to\jdk-11

# Linux/Mac
export CATALINA_HOME=/path/to/apache-tomcat-9.x
export JAVA_HOME=/path/to/jdk-11
```

2. Configure server ports (optional):

Edit `conf/server.xml`:

```xml
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

3. Increase session timeout (optional):

Edit `conf/web.xml` or `WebContent/WEB-INF/web.xml`:

```xml
<session-config>
    <session-timeout>60</session-timeout> <!-- in minutes -->
</session-config>
```

---

### 7. Start Tomcat Server

#### Windows

```bash
# Navigate to Tomcat bin directory
cd C:\path\to\apache-tomcat-9.x\bin

# Start server
startup.bat

# Or run as console
catalina.bat run
```

#### Linux/Mac

```bash
# Navigate to Tomcat bin directory
cd /path/to/apache-tomcat-9.x/bin

# Start server
./startup.sh

# Or run as console
./catalina.sh run
```

#### Check if Tomcat is Running

```bash
# Check process
ps aux | grep tomcat

# Check port
netstat -an | grep 8080

# Check logs
tail -f ../logs/catalina.out
```

---

### 8. Access the Application

Open web browser and navigate to:

```
http://localhost:8080/VendorFlow/
```

**Default Credentials:**

| Role | Email | Password | Shop Name |
|------|-------|----------|----------|
| Customer | amit@vendorflow.com | cust123 | - |
| Customer | sneha@vendorflow.com | cust123 | - |
| Vendor | ravi@vendorflow.com | vendor123 | Ravi Juice Center |
| Vendor | priya@vendorflow.com | vendor123 | Priya Snack Corner |
| Admin | admin@vendorflow.com | admin123 | - |

---

## Development Mode Setup

### Using Eclipse IDE

1. **Import Project**
   - File → Import → Dynamic Web Project
   - Select existing project: `VendorFlow`
   - Target runtime: Apache Tomcat v9.0

2. **Configure Build Path**
   - Right-click project → Build Path → Configure Build Path
   - Add External JARs:
     - `postgresql-42.7.3.jar`
     - `gson-2.10.1.jar`

3. **Set Deployment Assembly**
   - Project Properties → Deployment Assembly
   - Add Java Build Path Entries

4. **Run on Server**
   - Right-click project → Run As → Run on Server
   - Select Tomcat v9.0

---

### Using IntelliJ IDEA

1. **Import Project**
   - File → Open → Select `VendorFlow` folder
   - Select "Open as Project"

2. **Configure SDK**
   - File → Project Structure → Project
   - SDK: Java 11+

3. **Configure Tomcat**
   - Run → Edit Configurations
   - Add Tomcat Server → Local
   - Deployment tab: Add Artifact

4. **Run Application**
   - Click Run button

---

## Production Deployment

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| OS | Any (64-bit) | Linux (Ubuntu 20.04+) |
| RAM | 4 GB | 8 GB+ |
| CPU | 2 cores | 4 cores+ |
| Storage | 10 GB | 50 GB+ |
| Java | JDK 11 | JDK 17 (LTS) |
| Tomcat | 9.0 | 9.0+ |
| PostgreSQL | 12 | 14+ |

### Recommended Production Setup

```
                  ┌─────────────────┐
                  │   Load Balancer │
                  │   (Nginx/Haproxy)│
                  └────────┬────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
┌───────▼───────┐  ┌──────▼───────┐  ┌───────▼───────┐
│  Tomcat 1     │  │  Tomcat 2     │  │  Tomcat 3     │
│  (Instance)   │  │  (Instance)   │  │  (Instance)   │
└───────┬───────┘  └──────┬───────┘  └───────┬───────┘
        │                  │                  │
        └──────────────────┼──────────────────┘
                           │
                  ┌────────▼────────┐
                  │  PostgreSQL     │
                  │  (Primary)      │
                  └────────┬────────┘
                           │
                  ┌────────▼────────┐
                  │  PostgreSQL     │
                  │  (Replica)      │
                  └─────────────────┘
```

### 1. Configure Connection Pooling

Add to `context.xml`:

```xml
<Resource name="jdbc/vendorflow"
          auth="Container"
          type="javax.sql.DataSource"
          maxTotal="100"
          maxIdle="30"
          maxWaitMillis="10000"
          username="postgres"
          password="your_password"
          driverClassName="org.postgresql.Driver"
          url="jdbc:postgresql://localhost:5432/vendorflow"/>
```

### 2. Enable HTTPS

Generate certificate:

```bash
keytool -genkeypair -alias tomcat -keyalg RSA -keysize 2048 \
  -keystore /path/to/keystore.jks -validity 365
```

Configure `server.xml`:

```xml
<Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
           maxThreads="150" SSLEnabled="true">
  <SSLHostConfig>
    <Certificate certificateKeystoreFile="/path/to/keystore.jks"
                 type="RSA" />
  </SSLHostConfig>
</Connector>
```

### 3. Set Up Monitoring

```bash
# Install monitoring tools
apt-get install prometheus grafana

# Configure JVM monitoring
JAVA_OPTS="$JAVA_OPTS -javaagent:/path/to/prometheus/jmx_exporter.jar"
```

### 4. Configure Logging

```bash
# Edit conf/logging.properties
handlers = org.apache.juli.FileHandler, java.util.logging.ConsoleHandler

org.apache.juli.FileHandler.level = INFO
org.apache.juli.FileHandler.directory = ${catalina.base}/logs
org.apache.juli.FileHandler.prefix = vendorflow.
```

### 5. Set Up Automatic Startup

#### Systemd (Linux)

Create service file: `/etc/systemd/system/tomcat.service`

```ini
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/path/to/jdk"
Environment="CATALINA_HOME=/path/to/tomcat"
ExecStart=/path/to/tomcat/bin/startup.sh
ExecStop=/path/to/tomcat/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable service:

```bash
systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat
```

#### Windows

```powershell
# Install as service
tomcat9.exe //IS//Tomcat9

# Configure service
tomcat9.exe //US//Tomcat9 --JvmMs=128 --JvmMx=512
```

---

## Docker Deployment

### Option 1: Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:14
    environment:
      POSTGRES_DB: vendorflow
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: your_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./vendorflow.sql:/docker-entrypoint-initdb.d/schema.sql
    ports:
      - "5432:5432"

  tomcat:
    image: tomcat:9.0-jdk11
    volumes:
      - ./WebContent:/usr/local/tomcat/webapps/VendorFlow
      - ./postgresql-42.7.3.jar:/usr/local/tomcat/lib/postgresql.jar
      - ./gson-2.10.1.jar:/usr/local/tomcat/lib/gson.jar
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    environment:
      - DB_URL=jdbc:postgresql://postgres:5432/vendorflow

volumes:
  postgres_data:
```

Start services:

```bash
docker-compose up -d
```

### Option 2: Build Custom Image

Create `Dockerfile`:

```dockerfile
FROM tomcat:9.0-jdk11

# Install dependencies
RUN apt-get update && apt-get install -y postgresql-client

# Copy application
COPY WebContent /usr/local/tomcat/webapps/VendorFlow

# Copy libraries
COPY lib/*.jar /usr/local/tomcat/lib/

# Copy compiled classes
COPY WebContent/WEB-INF/classes /usr/local/tomcat/webapps/VendorFlow/WEB-INF/classes

# Configure database connection
ENV DB_URL=jdbc:postgresql://postgres:5432/vendorflow
ENV DB_USER=postgres
ENV DB_PASS=your_password

EXPOSE 8080
```

Build and run:

```bash
docker build -t vendorflow .
docker run -p 8080:8080 vendorflow
```

---

## Troubleshooting

### Application Not Starting

**Check Tomcat Logs:**

```bash
tail -f /path/to/tomcat/logs/catalina.out
```

**Common Issues:**

1. **Port 8080 already in use:**
   ```bash
   # Find process
   lsof -ti:8080
   # Kill or change port
   ```

2. **Database connection failed:**
   - Verify PostgreSQL is running
   - Check credentials in DBConnection.java
   - Test connection: `psql -U postgres -d vendorflow`

3. **Class not found:**
   - Ensure JARs in WEB-INF/lib
   - Check compiled classes in WEB-INF/classes

4. **Compilation errors:**
   ```bash
   javac -version
   # Should show 11 or higher
   ```

### Database Issues

**Connection Refused:**
```bash
# Check PostgreSQL status
systemctl status postgresql

# Start if stopped
systemctl start postgresql
```

**Permission Denied:**
```sql
-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE vendorflow TO postgres;
```

**Table Not Found:**
- Verify schema executed
- Check database name in connection string
- List tables: `\dt` in psql

---

### Performance Issues

**Slow Queries:**
```sql
-- Add indexes
CREATE INDEX idx_orders_vendor_id ON orders(vendor_id);
CREATE INDEX idx_orders_created ON orders(created_at);
```

**High Memory Usage:**
```bash
# Increase JVM heap
JAVA_OPTS="-Xms512m -Xmx2048m"
```

**Connection Leaks:**
- Ensure connections closed in finally blocks
- Implement connection pooling

---

### Session Issues

**Session Timeout Too Short:**
```xml
<!-- In web.xml -->
<session-config>
    <session-timeout>60</session-timeout>
</session-config>
```

**Session Not Persisting:**
- Check browser cookie settings
- Verify session cookie configuration
- Ensure no load balancer stripping cookies

---

## Updating the Application

### Deploy New Version

1. **Stop Tomcat:**
   ```bash
   ./shutdown.sh
   ```

2. **Backup Current Version:**
   ```bash
   cp -r webapps/VendorFlow webapps/VendorFlow.backup
   ```

3. **Deploy New Version:**
   ```bash
   rm -rf webapps/VendorFlow
   cp -r new_version/WebContent webapps/VendorFlow
   ```

4. **Migrate Database** (if schema changed):
   ```bash
   psql -U postgres -d vendorflow -f migration.sql
   ```

5. **Start Tomcat:**
   ```bash
   ./startup.sh
   ```

### Rollback

```bash
# Stop Tomcat
./shutdown.sh

# Restore backup
rm -rf webapps/VendorFlow
cp -r webapps/VendorFlow.backup webapps/VendorFlow

# Restore database (if needed)
pg_restore -U postgres -d vendorflow backup.dump

# Start Tomcat
./startup.sh
```

---

## Security Hardening

### 1. Change Default Passwords

```bash
# PostgreSQL
ALTER USER postgres WITH PASSWORD 'new_secure_password';

# Application database user
ALTER USER app_user WITH PASSWORD 'new_secure_password';
```

### 2. Enable SSL/TLS

**PostgreSQL:**
```sql
-- In postgresql.conf
ssl = on
ssl_cert_file = '/path/to/server.crt'
ssl_key_file = '/path/to/server.key'
```

**Application Connection:**
```java
jdbc:postgresql://localhost:5432/vendorflow?ssl=true&sslmode=require
```

### 3. Firewall Configuration

```bash
# Allow only necessary ports
ufw allow 22/tcp        # SSH
ufw allow 80/tcp        # HTTP
ufw allow 443/tcp       # HTTPS
ufw allow 5432/tcp      # PostgreSQL (internal only)
ufw enable
```

### 4. Regular Updates

```bash
# Update OS
apt-get update && apt-get upgrade

# Update Java
apt-get install openjdk-17-jdk

# Update Tomcat
# Download new version and migrate
```

### 5. Monitoring and Alerts

```bash
# Set up logwatch
apt-get install logwatch
logwatch --output mail --mailto admin@example.com

# Set up fail2ban
apt-get install fail2ban
```

---

## Backup and Recovery

### Daily Backup Script

Create `backup.sh`:

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/vendorflow"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup PostgreSQL
pg_dump -U postgres -d vendorflow -F c -f $BACKUP_DIR/vendorflow_$DATE.dump

# Backup application
cp -r /path/to/tomcat/webapps/VendorFlow $BACKUP_DIR/app_$DATE

# Compress
tar -czf $BACKUP_DIR/full_backup_$DATE.tar.gz $BACKUP_DIR/vendorflow_$DATE.dump $BACKUP_DIR/app_$DATE

# Remove old backups (older than 30 days)
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

# Log
echo "Backup completed: $DATE" >> /var/log/vendorflow_backup.log
```

Make executable:

```bash
chmod +x backup.sh
```

Add to cron:

```bash
crontab -e
# Add line:
0 2 * * * </path/to/>/backup.sh
```

### Recovery Procedure

**Restore Database:**
```bash
# Stop Tomcat
./shutdown.sh

# Drop existing database
psql -U postgres -c "DROP DATABASE vendorflow;"

# Create new database
psql -U postgres -c "CREATE DATABASE vendorflow;"

# Restore from backup
pg_restore -U postgres -d vendorflow /backups/vendorflow/vendorflow_20240507.dump
```

**Restore Application:**
```bash
# Remove current version
rm -rf webapps/VendorFlow

# Restore from backup
cp -r backups/vendorflow/app_20240507 webapps/VendorFlow

# Start Tomcat
./startup.sh
```

---

## Environment Variables

For production, use environment variables instead of hardcoded values:

### Create `.env` File

```bash
# Database Configuration
export DB_URL="jdbc:postgresql://localhost:5432/vendorflow"
export DB_USER="postgres"
export DB_PASS="secure_password"

# Application Configuration
export APP_PORT="8080"
export APP_DOMAIN="vendorflow.example.com"

# Logging
export LOG_LEVEL="INFO"

# Email Configuration (for future features)
export SMTP_HOST="smtp.example.com"
export SMTP_PORT="587"
export SMTP_USER="noreply@example.com"

# External Services
export CDN_URL="https://cdn.example.com"
export ANALYTICS_KEY="your_analytics_key"
```

### Load in Application

```java
String dbUrl = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPass = System.getenv("DB_PASS");
```

---

## Monitoring Checklist

- [ ] Application is accessible at `http://localhost:8080/VendorFlow`
- [ ] Login works with test credentials
- [ ] Database connection is established
- [ ] All pages load without errors
- [ ] Session management works correctly
- [ ] Orders can be placed successfully
- [ ] Queue updates in real-time
- [ ] Logs are being written to appropriate location
- [ ] No error messages in console
- [ ] Response times are acceptable (<2 seconds)
- [ ] Memory usage is stable
- [ ] Disk space is adequate
- [ ] Backup process is configured
- [ ] Monitoring alerts are set up

---

## Performance Tuning

### JVM Options

Edit `bin/setenv.sh` (create if doesn't exist):

```bash
CATALINA_OPTS="$CATALINA_OPTS -Xms512m"
CATALINA_OPTS="$CATALINA_OPTS -Xmx2048m"
CATALINA_OPTS="$CATALINA_OPTS -XX:+UseG1GC"
CATALINA_OPTS="$CATALINA_OPTS -XX:MaxGCPauseMillis=200"
CATALINA_OPTS="$CATALINA_OPTS -Djava.awt.headless=true"
```

### PostgreSQL Tuning

Edit `postgresql.conf`:

```ini
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 128MB
max_connections = 100
```

---

## Scaling Considerations

### Vertical Scaling
- Increase RAM and CPU
- Upgrade to faster disks (SSD/NVMe)
- Increase JVM heap size

### Horizontal Scaling
- Deploy multiple Tomcat instances
- Add load balancer (Nginx/HAProxy)
- Use database connection pooler (PgBouncer)
- Consider database read replicas

### Auto-Scaling (Cloud)
- Use AWS EC2 Auto Scaling or similar
- Containerize with Docker
- Deploy on Kubernetes
- Use managed database services (RDS)

---

## Maintenance Tasks

### Daily
- Monitor application logs
- Check disk space
- Verify backup completion

### Weekly
- Review performance metrics
- Analyze slow queries
- Update security patches

### Monthly
- Perform full backup test restore
- Review access logs
- Update application dependencies

### Quarterly
- Disaster recovery drill
- Performance benchmark testing
- Security audit

---

## Support Resources

- **Tomcat Documentation:** https://tomcat.apache.org/tomcat-9.0-doc/
- **PostgreSQL Documentation:** https://www.postgresql.org/docs/
- **Java Documentation:** https://docs.oracle.com/en/java/

---

## Conclusion

This deployment guide provides comprehensive instructions for setting up VendorFlow in development, staging, and production environments. Following these steps ensures a stable, secure, and performant deployment.

For issues or questions, please refer to the project documentation or contact the development team.

---
*Last Updated: 2026-05-07*
*Version: 1.0.0*
