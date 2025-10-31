pipeline {
  agent any

  parameters {
    string(name: 'TESTING_URL',  defaultValue: 'http://10.0.2.50/', description: 'URL of Testing (for Selenium)')
    string(name: 'TESTING_HOST', defaultValue: '10.0.2.50',        description: 'EC2 Testing host/IP for SCP')
    string(name: 'STAGING_HOST', defaultValue: '10.0.2.60',        description: 'EC2 Staging host/IP for SCP')
    string(name: 'PROD1_HOST',   defaultValue: '10.0.2.70',        description: 'EC2 Prod1 host/IP for SCP')
    string(name: 'PROD2_HOST',   defaultValue: '10.0.2.71',        description: 'EC2 Prod2 host/IP for SCP')
    string(name: 'DEPLOY_DIR',   defaultValue: '/var/www/html',    description: 'Remote deploy directory')
  }

  options { timestamps() }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Deploy to TESTING') {
      steps {
        sh """
          echo 'Deploying to TESTING...'
          scp -o StrictHostKeyChecking=no -r index.html js.js style.css ec2-user@${params.TESTING_HOST}:${params.DEPLOY_DIR}
        """
      }
    }

    stage('Selenium - validate Testing') {
      steps {
        sh """
          cd \$WORKSPACE
          npm install selenium-webdriver --no-fund --no-audit
          BASE_URL=${params.TESTING_URL} node tests/tic-tac-toe.test.js
        """
      }
    }

    stage('Deploy to STAGING') {
      when { success() }
      steps {
        sh """
          echo 'Deploying to STAGING...'
          scp -o StrictHostKeyChecking=no -r index.html js.js style.css ec2-user@${params.STAGING_HOST}:${params.DEPLOY_DIR}
        """
      }
    }

    stage('Deploy to PROD_1') {
      when { success() }
      steps {
        sh """
          echo 'Deploying to PROD_1...'
          scp -o StrictHostKeyChecking=no -r index.html js.js style.css ec2-user@${params.PROD1_HOST}:${params.DEPLOY_DIR}
        """
      }
    }

    stage('Deploy to PROD_2') {
      when { success() }
      steps {
        sh """
          echo 'Deploying to PROD_2...'
          scp -o StrictHostKeyChecking=no -r index.html js.js style.css ec2-user@${params.PROD2_HOST}:${params.DEPLOY_DIR}
        """
      }
    }
  }

  post {
    always {
      echo 'Pipeline finished.'
    }
  }
}
