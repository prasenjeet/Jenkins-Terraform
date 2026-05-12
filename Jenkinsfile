pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'prod'],
            description: 'Target deployment environment'
        )
        choice(
            name: 'TF_ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform action to execute'
        )
    }

    environment {
        TF_DIR        = "terraform/environments/${params.ENVIRONMENT}"
        TF_VERSION    = '1.7.5'
        TF_IN_AUTOMATION = 'true'
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    options {
        ansiColor('xterm')
        timestamps()
        timeout(time: 60, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
    }

    stages {
        // ──────────────────────────────────────────────
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    currentBuild.displayName = "#${BUILD_NUMBER} | ${params.ENVIRONMENT} | ${params.TF_ACTION}"
                }
            }
        }

        // ──────────────────────────────────────────────
        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh """
                        chmod +x scripts/tf-init.sh
                        scripts/tf-init.sh ${params.ENVIRONMENT}
                    """
                }
            }
        }

        // ──────────────────────────────────────────────
        stage('Terraform Validate') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh "terraform -chdir=${TF_DIR} validate"
                }
            }
        }

        // ──────────────────────────────────────────────
        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh """
                        chmod +x scripts/tf-plan.sh
                        scripts/tf-plan.sh ${params.ENVIRONMENT} ${params.TF_ACTION}
                    """
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: "${TF_DIR}/tfplan.binary", allowEmptyArchive: true
                }
            }
        }

        // ──────────────────────────────────────────────
        stage('Approval Gate') {
            when {
                expression { params.TF_ACTION in ['apply', 'destroy'] }
            }
            steps {
                script {
                    def actionColor = params.TF_ACTION == 'destroy' ? '⚠️  DESTROY' : '✅  APPLY'
                    timeout(time: 15, unit: 'MINUTES') {
                        input(
                            message: "${actionColor} — ${params.ENVIRONMENT.toUpperCase()} environment?",
                            ok: "Proceed with ${params.TF_ACTION}",
                            submitter: 'jenkins-approvers'
                        )
                    }
                }
            }
        }

        // ──────────────────────────────────────────────
        stage('Terraform Apply') {
            when {
                expression { params.TF_ACTION == 'apply' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh """
                        chmod +x scripts/tf-apply.sh
                        scripts/tf-apply.sh ${params.ENVIRONMENT}
                    """
                }
            }
        }

        // ──────────────────────────────────────────────
        stage('Terraform Destroy') {
            when {
                expression { params.TF_ACTION == 'destroy' }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh """
                        chmod +x scripts/tf-destroy.sh
                        scripts/tf-destroy.sh ${params.ENVIRONMENT}
                    """
                }
            }
        }
    }

    // ──────────────────────────────────────────────────
    post {
        success {
            echo "Pipeline succeeded: ${params.TF_ACTION} on ${params.ENVIRONMENT}"
        }
        failure {
            echo "Pipeline FAILED: ${params.TF_ACTION} on ${params.ENVIRONMENT}"
            // Add email/Slack notification step here, e.g.:
            // slackSend channel: '#infra-alerts', color: 'danger',
            //   message: "TF ${params.TF_ACTION} FAILED on ${params.ENVIRONMENT} — ${BUILD_URL}"
        }
        always {
            cleanWs()
        }
    }
}
