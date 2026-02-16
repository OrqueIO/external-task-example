# OrqueIO External Task Example

[![OrqueIO](https://img.shields.io/badge/OrqueIO-1.0.7--SNAPSHOT-blue.svg)](https://orqueio.io)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.1-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-17+-orange.svg)](https://openjdk.org/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A complete, ready-to-run Spring Boot application demonstrating the **External Task Pattern** with OrqueIO BPM engine. This all-in-one example includes both the OrqueIO engine and an external task worker in a single application.

##  Table of Contents

- [Overview](#overview)
- [What are External Tasks?](#what-are-external-tasks)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Customization](#customization)
- [API Reference](#api-reference)

##  Overview

This project demonstrates how to implement the **External Task Pattern** using OrqueIO, a powerful open-source BPM platform. Unlike traditional service tasks that run synchronously within the engine, external tasks enable:

- ✅ **Decoupled architecture** - Workers run independently from the engine
- ✅ **Horizontal scalability** - Multiple workers can process the same topic
- ✅ **Fault tolerance** - Automatic retry and error handling
- ✅ **Technology flexibility** - Workers can be written in any language
- ✅ **Microservices ready** - Perfect for distributed systems

##  What are External Tasks?

External Tasks implement the **poll-based** service invocation pattern:

```
┌─────────────────────┐         ┌──────────────────────┐
│   OrqueIO Engine    │         │   External Worker    │
│   (Port 8080)       │         │   (Java Application) │
│                     │         │                      │
│  1. Creates task    │         │  1. Polls for tasks  │
│  2. Waits for       │◄────────┤  2. Locks task       │
│     completion      │  Poll   │  3. Executes logic   │
│  3. Continues       │◄────────┤  4. Completes task   │
│     process         │ Complete│                      │
└─────────────────────┘         └──────────────────────┘
```

**Key differences from traditional Service Tasks:**

| Aspect | Service Task | External Task |
|--------|--------------|---------------|
| **Execution** | Synchronous, in-engine | Asynchronous, external process |
| **Coupling** | Tightly coupled | Loosely coupled |
| **Scalability** | Limited to engine threads | Unlimited workers |
| **Fault Tolerance** | Engine transaction rollback | Retry mechanism with backoff |
| **Technology** | Must be Java | Any language with HTTP client |

##  Features

### Included in this Example

-  **Complete OrqueIO BPM Engine** with REST API
-  **External Task Worker** with automatic polling
-  **H2 In-Memory Database** (no external DB required)
-  **Auto-deployment** of BPMN processes
-  **Web UI** for manual task completion (`/manual-complete.html`)
-  **OrqueIO Cockpit** for process monitoring
-  **Test scripts** (Bash and Batch)
-  **Comprehensive logging** and error handling
-  **Retry mechanism** with exponential backoff
-  **Lock duration management** to prevent duplicate processing

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│            external-task-example (Port 8080)             │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │              OrqueIO BPM Engine                    │ │
│  │  • H2 In-Memory Database                           │ │
│  │  • REST API (/engine-rest)                         │ │
│  │  • Cockpit UI                                      │ │
│  │  • Process Engine (BPMN execution)                 │ │
│  └─────────────────────┬──────────────────────────────┘ │
│                        │                                 │
│                        │ HTTP REST API                   │
│                        │                                 │
│  ┌─────────────────────▼──────────────────────────────┐ │
│  │         SampleExternalTaskWorker                   │ │
│  │  • Polls topic: "process-data"                     │ │
│  │  • Lock duration: 10 seconds                       │ │
│  │  • Processes business logic                        │ │
│  │  • Completes tasks with results                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│            ALL IN ONE APPLICATION!                       │
└──────────────────────────────────────────────────────────┘
```

##  Prerequisites

- **Java 17+** - [Download OpenJDK](https://adoptium.net/)
- **Maven 3.6+** - [Download Maven](https://maven.apache.org/download.cgi)
- **SpringBoot 3.x** 
- **Git** (for cloning the repository)

**No external database or additional services required!**

##  Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/OrqueIO/external-task-example.git
cd external-task-example
```

### 2. Build the Application

```bash
mvn clean install
```

### 3. Run the Application

```bash
mvn spring-boot:run
```

The application will start and perform the following:
- ✅ Start OrqueIO engine on **http://localhost:8080**
- ✅ Initialize H2 in-memory database
- ✅ Auto-deploy BPMN process from `src/main/resources/bpmn/`
- ✅ Start external task worker listening to topic `"process-data"`

**Wait for this log message:**
```
External Task Worker is now listening to topic: process-data
```

##  Testing

### Option 1: REST API (Quick Test)

Start a process instance with curl:

```bash
curl -X POST http://localhost:8080/engine-rest/process-definition/key/ExternalTaskProcess/start \
  -H "Content-Type: application/json" \
  -d '{
    "variables": {
      "inputData": {
        "value": "Hello OrqueIO",
        "type": "String"
      }
    }
  }'
```

**Expected output in logs:**
```
INFO : External task received: [task-id]
INFO : Activity ID: ExternalTask_ProcessData
INFO : Variables: {inputData=Hello OrqueIO}
INFO : Input data: Hello OrqueIO
INFO : Processed data: PROCESSED: HELLO ORQUEIO
INFO : External task completed successfully: [task-id]
```

### Option 2: OrqueIO Cockpit (Visual Interface)

1. Open browser: **http://localhost:8080**
2. Login with credentials:
   - Username: `admin`
   - Password: `admin`
3. Navigate to **Cockpit**
4. View the deployed process: **"External Task Sample Process"**
5. Start a new process instance
6. Add variable: `inputData` = `"Hello World"` (type: String)
7. Watch the worker process the task in real-time!

### Option 3: Manual Completion UI

For testing without the automatic worker:

1. Open: **http://localhost:8080/manual-complete.html**
2. Comment out `@Component` in `SampleExternalTaskWorker.java` to disable auto-worker
3. Use the web interface to manually fetch and complete tasks

### Option 4: Test Scripts

Run the provided test scripts:

**Windows:**
```bash
test-api.bat
```

**Linux/Mac/Git Bash:**
```bash
chmod +x test-api.sh
./test-api.sh
```

##  Project Structure

```
external-task-example/
├── src/
│   └── main/
│       ├── java/
│       │   └── io/orqueio/externaltask/
│       │       ├── ExternalTaskApplication.java      # Spring Boot main class
│       │       └── worker/
│       │           └── SampleExternalTaskWorker.java # External task worker
│       └── resources/
│           ├── application.yml                       # Application configuration
│           ├── bpmn/
│           │   └── sample_external_task_process.bpmn # Auto-deployed process
│           ├── static/
│           │   └── manual-complete.html              # Manual completion UI
│           └── sample_external_task_process.bpmn     # BPMN source
├── test-api.sh                                       # Linux test script
├── test-api.bat                                      # Windows test script
├── manual-external-task.sh                           # Manual task completion script
├── pom.xml                                           # Maven configuration
└── README.md                                         # This file
```

## ⚙ Configuration

### Application Properties

Configuration file: `src/main/resources/application.yml`

```yaml
server:
  port: 8080                        # Application port

spring:
  datasource:
    url: jdbc:h2:mem:orqueio        # H2 in-memory database
    driver-class-name: org.h2.Driver
  h2:
    console:
      enabled: true                  # H2 console at /h2-console
      path: /h2-console

orqueio:
  bpm:
    rest-api:
      basic-auth-enabled: false      # Disable auth for development
    database:
      schema-update: true            # Auto-update DB schema
    admin-user:
      id: admin
      password: admin
    deployment-resource-pattern: classpath*:bpmn/*.bpmn  # Auto-deploy
  base-url: http://localhost:8080/engine-rest            # Worker connection
```

##  API Reference

### REST Endpoints

All REST endpoints are available at `http://localhost:8080/engine-rest/`

#### Start Process Instance

```bash
POST /engine-rest/process-definition/key/{key}/start
Content-Type: application/json

{
  "variables": {
    "variableName": {
      "value": "variableValue",
      "type": "String"
    }
  }
}
```

#### Fetch and Lock External Tasks

```bash
POST /engine-rest/external-task/fetchAndLock
Content-Type: application/json

{
  "workerId": "worker-id",
  "maxTasks": 10,
  "topics": [
    {
      "topicName": "process-data",
      "lockDuration": 10000
    }
  ]
}
```

#### Complete External Task

```bash
POST /engine-rest/external-task/{taskId}/complete
Content-Type: application/json

{
  "workerId": "worker-id",
  "variables": {
    "resultVar": {
      "value": "result",
      "type": "String"
    }
  }
}
```

#### Handle Failure

```bash
POST /engine-rest/external-task/{taskId}/failure
Content-Type: application/json

{
  "workerId": "worker-id",
  "errorMessage": "Error description",
  "retries": 3,
  "retryTimeout": 5000
}
```

### Complete API Documentation

- **Full REST API**: http://localhost:8080/engine-rest
- **H2 Console**: http://localhost:8080/h2-console
- **Manual Completion UI**: http://localhost:8080/manual-complete.html

##  Troubleshooting

### Issue: Worker not processing tasks

**Solution:**
- Check logs for "External Task Worker is now listening"
- Verify the topic name matches in BPMN and worker code
- Ensure the process instance was started successfully
- Check if tasks are locked by another worker

### Issue: Connection refused

**Solution:**
- Ensure the engine is fully started before the worker connects
- The worker waits 5 seconds by default - increase if needed
- Check the `orqueio.base-url` configuration

### Issue: BPMN not auto-deployed

**Solution:**
- Verify BPMN file is in `src/main/resources/bpmn/`
- Check for BPMN validation errors in logs
- Ensure `historyTimeToLive` is set in the BPMN process

### Issue: Database errors

**Solution:**
- H2 database is recreated on each startup (in-memory)
- For persistent data, configure MySQL or PostgreSQL in `application.yml`

### Enable Debug Logging

Add to `application.yml`:

```yaml
logging:
  level:
    io.orqueio: DEBUG
    io.orqueio.externaltask: DEBUG
```

##  License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

##  Support

- **Issues**: [GitHub Issues](https://github.com/orqueio/external-task-example/issues)
- **Discussions**: [GitHub Discussions](https://github.com/orqueio/external-task-example/discussions)
- **Community**: Join our [Discord Server](https://discord.gg/orqueio)

---

Made with ❤️ by the [OrqueIO Team](https://orqueio.io)
