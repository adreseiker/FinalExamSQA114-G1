pipeline {
  agent none

  parameters {
    string(name: 'TESTING_HOST',  defaultValue: '', description: 'IP/host of "Testing" instance')
    string(name: 'STAGING_HOST',  defaultValue: '', description: 'IP/host of "Staging" instance')
    string(name: 'PROD1_HOST',    defaultValue: '', description: 'IP/host of "Production_Env1" instance')
    string(name: 'PROD2_HOST',    defaultValue: '', description: 'IP/host of "Production_Env2" instance')
    string(name: 'REMOTE_DIR',    defaultValue: '/var/www/html', description: 'Remote web root (Apache)')
  }

  options { timestamps() }
  triggers { githubPush() }

  stages {
    stage('Checkout (permanent)') {
      agent { label 'JenkinsAgentPermanent' }
      steps {
        checkout scm
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
        sh """
          set -e
          if [ -z "${params.TESTING_HOST}" ]; then
            echo "TESTING_HOST is empty"; exit 1
          fi
          scp -o StrictHostKeyChecking=no -r index.html js.js style.css ec2-user@${params.TESTING_HOST}:${params.REMOTE_DIR}
        """
      }
    }

    stage('Selenium on TESTING') {
      agent { label 'JenkinsAgentDynamic' }
      steps {
        sh """
          set -e
          npm install selenium-webdriver --no-fund --no-audit
          BASE_URL=http://${params.TESTING_HOST}/ node tests/tic-tac-toe.test.js
        """
      }
    }

    stage('Deploy to STAGING') {
      when { succeeded() }
      agent { label 'JenkinsAgentPermanent' }
      steps {
        sh """
          set -e
          if [ -z "${params.STAGING_HOST}" ]; then
            echo "STAGING_HOST is empty"; exit 1
          fi
          scp -o StrictHostKeyChecking=no -r index.html js.js style.css ec2-user@${params.STAGING_HOST}:${params.REMOTE_DIR}
        """
      }
    }

    stage('Selenium on STAGING') {
      when { succeeded() }
      agent { label 'JenkinsAgentDynamic' }
      steps {
        sh """
          set -e
          BASE_URL=http://${params.STAGING_HOST}/ node tests/tic-tac-toe.test.js
        """
      }
    }

    stage('Deploy to Production_Env1') {
      when { succeeded() }
      agent { label 'JenkinsAgentPermanent' }
      steps {
        sh """
          set -e
          if [ -z "${params.PROD1_HOST}" ]; then
            echo "PROD1_HOST is empty"; exit 1
          fi
          scp -o StrictHostKeyChecking=no -r index.html js.js style.css ec2-user@${params.PROD1_HOST}:${params.REMOTE_DIR}
        """
      }
    }

    stage('Deploy to Production_Env2') {
      when { succeeded() }
      agent { label 'JenkinsAgentPermanent' }
      steps {
        sh """
          set -e
          if [ -z "${params.PROD2_HOST}" ]; then
            echo "PROD2_HOST is empty"; exit 1
          fi
          scp -o StrictHostKeyChecking=no -r index.html js.js style.css ec2-user@${params.PROD2_HOST}:${params.REMOTE_DIR}
        """
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'tests/**', onlyIfSuccessful: false
    }
  }
}
