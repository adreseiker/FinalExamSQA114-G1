```groovy
properties([
  parameters([
    string(name: 'TESTING_HOST',  defaultValue: '', description: 'IP/host TESTING'),
    string(name: 'STAGING_HOST',  defaultValue: '', description: 'IP/host STAGING'),
    string(name: 'PROD1_HOST',    defaultValue: '', description: 'IP/host PRODUCTION_ENV1'),
    string(name: 'PROD2_HOST',    defaultValue: '', description: 'IP/host PRODUCTION_ENV2'),
    string(name: 'REMOTE_DIR',    defaultValue: '/var/www/html', description: 'Remote web dir (Apache)'),
    string(name: 'SSH_KEY_PATH',  defaultValue: '/home/ec2-user/.ssh/finalexam.pem', description: 'SSH key created by Terraform and copied to agent')
  ])
])

pipeline {
  agent none
  options { timestamps() }
  triggers { githubPush() }

  stages {
    stage('Checkout (permanent)') {
      agent { label 'JenkinsAgentPermanent' }
      steps {
        checkout scm
        stash name: 'app', includes: '**/*'
        echo "Targets:"
        echo "  Testing         -> ${params.TESTING_HOST}"
        echo "  Staging         -> ${params.STAGING_HOST}"
        echo "  Production_Env1 -> ${params.PROD1_HOST}"
        echo "  Production_Env2 -> ${params.PROD2_HOST}"
      }
    }

    stage('Deploy to TESTING') {
      agent { label 'JenkinsAgentPermanent' }
      steps {
        unstash 'app'
        sh """
          set -e
          if [ -z "${params.TESTING_HOST}" ]; then
            echo "TESTING_HOST is empty"; exit 1
          fi
          scp -i ${params.SSH_KEY_PATH} -o StrictHostKeyChecking=no -r \
            index.html js.js style.css ec2-user@${params.TESTING_HOST}:${params.REMOTE_DIR}
        """
      }
    }

    stage('Selenium on TESTING') {
      agent { label 'JenkinsAgentDynamic' }
      steps {
        unstash 'app'
        sh """
          set -e
          npm install selenium-webdriver --no-fund --no-audit
          BASE_URL=http://${params.TESTING_HOST}/ node tests/tic-tac-toe.test.js
        """
      }
    }

    stage('Deploy to STAGING') {
      agent { label 'JenkinsAgentPermanent' }
      steps {
        unstash 'app'
        sh """
          set -e
          if [ -z "${params.STAGING_HOST}" ]; then
            echo "STAGING_HOST is empty"; exit 1
          fi
          scp -i ${params.SSH_KEY_PATH} -o StrictHostKeyChecking=no -r \
            index.html js.js style.css ec2-user@${params.STAGING_HOST}:${params.REMOTE_DIR}
        """
      }
    }

    stage('Selenium on STAGING') {
      agent { label 'JenkinsAgentDynamic' }
      steps {
        unstash 'app'
        sh """
          set -e
          BASE_URL=http://${params.STAGING_HOST}/ node tests/tic-tac-toe.test.js
        """
      }
    }

    stage('Deploy to Production_Env1') {
      agent { label 'JenkinsAgentPermanent' }
      steps {
        unstash 'app'
        sh """
          set -e
          if [ -z "${params.PROD1_HOST}" ]; then
            echo "PROD1_HOST is empty"; exit 1
          fi

          # build PROD1 version from index.html
          cp index.html index-prod1.html
          sed -i 's|<body onload="initialize()">|<body onload="initialize()">\\n  <p style="text-align:center;font-weight:bold;font-size:28px;margin:14px 0;">Environment: Production_Env1</p>|' index-prod1.html

          scp -i ${params.SSH_KEY_PATH} -o StrictHostKeyChecking=no \
            index-prod1.html ec2-user@${params.PROD1_HOST}:${params.REMOTE_DIR}/index.html

          scp -i ${params.SSH_KEY_PATH} -o StrictHostKeyChecking=no \
            js.js style.css ec2-user@${params.PROD1_HOST}:${params.REMOTE_DIR}
        """
      }
    }

    stage('Deploy to Production_Env2') {
      agent { label 'JenkinsAgentPermanent' }
      steps {
        unstash 'app'
        sh """
          set -e
          if [ -z "${params.PROD2_HOST}" ]; then
            echo "PROD2_HOST is empty"; exit 1
          fi

          cp index.html index-prod2.html
          sed -i 's|<body onload="initialize()">|<body onload="initialize()">\\n  <p style="text-align:center;font-weight:bold;font-size:28px;margin:14px 0;">Environment: Production_Env2</p>|' index-prod2.html

          scp -i ${params.SSH_KEY_PATH} -o StrictHostKeyChecking=no \
            index-prod2.html ec2-user@${params.PROD2_HOST}:${params.REMOTE_DIR}/index.html

          scp -i ${params.SSH_KEY_PATH} -o StrictHostKeyChecking=no \
            js.js style.css ec2-user@${params.PROD2_HOST}:${params.REMOTE_DIR}
        """
      }
    }
  }

  post {
    always {
      node('JenkinsAgentPermanent') {
        archiveArtifacts artifacts: 'tests/**', onlyIfSuccessful: false
      }
    }
  }
}
