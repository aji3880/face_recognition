pipeline {
    agent any

    environment {
        NAMESPACE = "face-recognition"
        APP_NAME = "face-recognition"
        OCP_API = "https://api.cluster-f4k2h.dynamic.redhatworkshops.io:6443"
        IMAGE_REGISTRY = "image-registry.openshift-image-registry.svc:5000"
        IMAGE_TAG = "latest"
        COMPOSE_FILE = "docker-compose.yml"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('login') {
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

        stage('install docker') {
            steps {
                sh '''
                echo "Installing docker-compose locally..."
                mkdir -p ./bin
                curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o ./bin/docker-compose
                chmod +x ./bin/docker-compose
                ./bin/docker-compose version
                '''
            }
        }

        stage('build images') {
            steps {
                sh '''
                sudo ./bin/docker-compose -f ${COMPOSE_FILE} build
                echo "Building image using docker-compose..."
                ./bin/docker-compose -f ${COMPOSE_FILE} build
                '''
            }
        }

        stage('test docker image') {
            steps {
                sh '''
                echo "Running container locally for test..."
                ./bin/docker-compose -f ${COMPOSE_FILE} up -d
                sleep 5
                docker ps
                ./bin/docker-compose -f ${COMPOSE_FILE} logs --tail=10
                ./bin/docker-compose -f ${COMPOSE_FILE} down
                '''
            }
        }

        stage('push') {
            steps {
                sh '''
                echo "Tagging image for OpenShift internal registry..."
                docker tag ${APP_NAME}:latest ${IMAGE_REGISTRY}/${NAMESPACE}/${APP_NAME}:${IMAGE_TAG}

                echo "Logging in to OpenShift image registry..."
                docker login -u kubeadmin -p $(oc whoami -t) --insecure ${IMAGE_REGISTRY}

                echo "Pushing image to OpenShift internal registry..."
                docker push ${IMAGE_REGISTRY}/${NAMESPACE}/${APP_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('deployt') {
            steps {
                sh '''
                echo "Deploying container to OpenShift..."
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
            echo "Successfully built and deployed via docker-compose"
        }
        failure {
            echo "Build or deploy failed. Check Jenkins logs for details."
        }
    }
}
