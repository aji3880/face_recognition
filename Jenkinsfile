pipeline {
    agent any

    environment {
        NAMESPACE = "face-recognition"
        APP_NAME = "face-recognition"
        OCP_API = "https://api.cluster-f4k2h.dynamic.redhatworkshops.io:6443"
        IMAGE_REGISTRY = "image-registry.openshift-image-registry.svc:5000"
        IMAGE_TAG = "latest"
        COMPOSE_FILE = "docker-compose.yml"
        DOCKER_COMPOSE = "./bin/docker-compose"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Login OpenShift') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'ocp-crd', usernameVariable: 'OCP_USER', passwordVariable: 'OCP_PASS')]) {
                    sh '''
                    echo "Logging in to OpenShift..."
                    oc login ${OCP_API} -u ${OCP_USER} -p ${OCP_PASS} --insecure-skip-tls-verify=true

                    if ! oc get project ${NAMESPACE} >/dev/null 2>&1; then
                        oc new-project ${NAMESPACE} --description="Face Recognition App"
                    fi
                    oc project ${NAMESPACE}
                    '''
                }
            }
        }

        stage('buildconfig') {
            steps {
                script {
                    // Pilih Dockerfile berdasarkan parameter
                    def dockerfile = params.USE_GPU ? 'Dockerfile.gpu' : 'Dockerfile'

                    sh """
                    echo "Checking if BuildConfig exists..."
                    if ! oc get bc ${APP_NAME} -n ${NAMESPACE} >/dev/null 2>&1; then
                        echo "Creating new BuildConfig (binary strategy)..."
                        oc new-build --name=${APP_NAME} --binary --strategy=docker-compose -n ${NAMESPACE}
                    fi
                    """
                }
            }
        }


        stage('Push to OpenShift Registry') {
            steps {
                sh '''
                echo "Tagging image for OpenShift internal registry..."
                sudo docker tag ${APP_NAME}:latest ${IMAGE_REGISTRY}/${NAMESPACE}/${APP_NAME}:${IMAGE_TAG}

                echo "Logging in to OpenShift internal registry..."
                oc whoami -t | sudo docker login -u kubeadmin --password-stdin ${IMAGE_REGISTRY}

                echo "Pushing image..."
                sudo docker push ${IMAGE_REGISTRY}/${NAMESPACE}/${APP_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy to OpenShift') {
            steps {
                sh '''
                echo "Deploying image to OpenShift..."
                if oc get deployment ${APP_NAME} -n ${NAMESPACE} >/dev/null 2>&1; then
                    oc set image deployment/${APP_NAME} ${APP_NAME}=${IMAGE_REGISTRY}/${NAMESPACE}/${APP_NAME}:${IMAGE_TAG} -n ${NAMESPACE}
                    oc rollout restart deployment/${APP_NAME} -n ${NAMESPACE}
                else
                    oc new-app ${IMAGE_REGISTRY}/${NAMESPACE}/${APP_NAME}:${IMAGE_TAG} -n ${NAMESPACE}
                fi
                '''
            }
        }
    }

    post {
        success {
            echo "Successfully built and deployed using Docker Compose and OpenShift"
        }
        failure {
            echo "Build or deploy failed. Check Jenkins logs for details."
        }
    }
}
