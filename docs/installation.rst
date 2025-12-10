============
Installation
============

This guide provides detailed installation instructions for all components of Amadeus.

System Requirements
===================

iOS Application
---------------

**Minimum Requirements:**

* iOS 18.0 or later
* iPhone 8 or newer
* Internet connection for analysis

**Development Requirements:**

* macOS 13.0+
* Xcode 15.0+
* Swift 5.0+

Python Server
-------------

**Minimum Requirements:**

* Python 3.8+

**Recommended:**

* Python 3.11+ (performance improvements)


Development Setup
=================

macOS Installation
------------------

**1. Install Homebrew (if not installed):**

.. code-block:: bash

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

**2. Install Python:**

.. code-block:: bash

    brew install python@3.11
    python3 --version  # Verify installation

**3. Install Xcode:**

* Download from Mac App Store
* Or download from https://developer.apple.com/xcode/
* Install Xcode Command Line Tools:

.. code-block:: bash

    xcode-select --install

**4. Clone Repository:**

.. code-block:: bash

    git clone https://github.com/yourusername/amadeus.git
    cd amadeus

**5. Set Up Python Server:**

.. code-block:: bash

    cd basic-pitch-server
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt

**6. Download Model Weights:**

The Basic Pitch model will be downloaded automatically on first run.
To pre-download:

.. code-block:: python

    python -c "import basic_pitch; print('Model ready')"

**7. Configure iOS App:**

.. code-block:: bash

    cd ../Amadeus-Fresh/amadeus
    open amadeus.xcodeproj

In Xcode:

1. Select your development team
2. Update bundle identifier if needed
3. Configure signing certificates

Production Deployment
=====================

Server Deployment
-----------------

**Option 1: Cloud Platform (Recommended)**

AWS EC2 Example:

.. code-block:: bash

    # Launch EC2 instance (t3.medium or larger)
    # SSH into instance
    
    # Install dependencies
    sudo apt update
    sudo apt install python3.11 python3.11-venv nginx supervisor

    # Clone and setup
    git clone https://github.com/yourusername/amadeus.git
    cd amadeus/basic-pitch-server
    python3.11 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    pip install gunicorn

    # Configure supervisor
    sudo nano /etc/supervisor/conf.d/amadeus.conf

Supervisor configuration:

.. code-block:: ini

    [program:amadeus]
    command=/home/ubuntu/amadeus/basic-pitch-server/venv/bin/gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker -b 127.0.0.1:8000
    directory=/home/ubuntu/amadeus/basic-pitch-server
    user=ubuntu
    autostart=true
    autorestart=true
    redirect_stderr=true
    stdout_logfile=/var/log/amadeus.log

**Option 2: Kubernetes**

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: amadeus-server
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: amadeus
      template:
        metadata:
          labels:
            app: amadeus
        spec:
          containers:
          - name: server
            image: amadeus-server:latest
            ports:
            - containerPort: 8000
            resources:
              requests:
                memory: "2Gi"
                cpu: "1000m"
              limits:
                memory: "4Gi"
                cpu: "2000m"

iOS App Distribution
--------------------

**TestFlight (Beta Testing):**

1. Archive app in Xcode (Product → Archive)
2. Upload to App Store Connect
3. Submit for TestFlight review
4. Invite beta testers

**App Store Release:**

1. Prepare app metadata
2. Create screenshots for all device sizes
3. Write app description
4. Submit for App Store review
5. Release when approved

Configuration
=============

Environment Variables
---------------------

Create ``.env`` file in server directory:

.. code-block:: bash

    # Server settings
    HOST=0.0.0.0
    PORT=8000
    WORKERS=4

    # Model settings
    MODEL_PATH=/path/to/model
    MAX_FILE_SIZE_MB=50

    # Performance
    ENABLE_CACHE=true
    CACHE_TTL=3600

iOS Configuration
-----------------

Create ``Config.swift``:

.. code-block:: swift

    struct Config {
        static let serverURL = ProcessInfo.processInfo.environment["SERVER_URL"] 
            ?? "https://api.amadeus.app"
        
        static let maxRecordingDuration: TimeInterval = 30
        static let maxFileSize = 50 * 1024 * 1024  // 50MB
    }

Verification
============

Test Server
-----------

.. code-block:: bash

    # Health check
    curl http://localhost:8000/health

    # Test analysis
    curl -X POST -F "file=@test.mp3" http://localhost:8000/analyze

Test iOS App
------------

1. Run app in simulator
2. Select test audio file
3. Verify analysis completes
4. Check chord timeline displays
5. Test playback controls

Troubleshooting
===============

Common Issues
-------------

**ImportError: No module named 'basic_pitch'**

.. code-block:: bash

    pip install --force-reinstall basic-pitch

**Server fails to start: Address already in use**

.. code-block:: bash

    # Find and kill process using port 8000
    lsof -i :8000
    kill -9 <PID>

**iOS app can't connect to server**

1. Check server is running
2. Verify firewall allows port 8000
3. For device testing, use computer's IP address
4. Ensure both devices on same network

**Model download fails**

.. code-block:: bash

    # Manually download model
    wget https://github.com/spotify/basic-pitch/releases/download/v0.2.0/basic_pitch_model.tar.gz
    tar -xzf basic_pitch_model.tar.gz
    mv model ~/.basic_pitch/

Support
=======

For installation help:

* GitHub Issues: https://github.com/cucuwritescode/amadeus/issues
* Documentation: https://amadeus.readthedocs.io