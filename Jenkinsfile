pipeline {
    agent any

    environment {
        NAMESPACE = "face-recognition"
        APP_NAME = "face-recognition"
        OCP_API = "https://api.cluster-f4k2h.dynamic.redhatworkshops.io:6443"
        HELM_VERSION = "v3.15.4"
        IMAGE_REGISTRY = "image-registry.openshift-image-registry.svc:5000"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Login to OpenShift') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'ocp-crd', usernameVariable: 'OCP_USER', passwordVariable: 'OCP_PASS')]) {
                    sh '''
                    echo "Logging in to OpenShift..."
                    oc login ${OCP_API} -u ${OCP_USER} -p ${OCP_PASS} --insecure-skip-tls-verify=true
                    if ! oc get project ${NAMESPACE} >/dev/null 2>&1; then
                        oc new-project ${NAMESPACE} --description="Project for ${APP_NAME}"
                    fi
                    oc project ${NAMESPACE}
                    '''
                }
            }
        }

        stage('Create/OpenShift BuildConfig') {
            steps {
                sh '''
                echo "Creating BuildConfig if not exists..."
                if ! oc get bc ${APP_NAME} -n ${NAMESPACE} >/dev/null 2>&1; then
                    oc new-build --name=${APP_NAME} --binary --strategy=docker -n ${NAMESPACE}
                fi
                '''
            }
        }

        stage('Build Image in OpenShift') {
            steps {
                sh '''
                echo "Starting OpenShift binary build..."
                oc start-build ${APP_NAME} --from-dir=. --follow -n ${NAMESPACE}
                '''
            }
        }

        stage('Install Helm') {
            steps {
                sh '''
                echo "Installing Helm..."
                curl -sSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz
                tar -xzf helm.tar.gz
                mkdir -p "$WORKSPACE/bin"
                mv linux-amd64/helm "$WORKSPACE/bin/helm"
                export PATH="$WORKSPACE/bin:$PATH"
                "$WORKSPACE/bin/helm" version
                '''
            }
        }

        stage('Deploy with Helm') {
            steps {
                sh '''
                echo "Deploying with Helm..."
                export PATH=$WORKSPACE/bin:$PATH
                helm upgrade --install ${APP_NAME} ./helm-chart \
                  --set image.repository=${IMAGE_REGISTRY}/${NAMESPACE}/${APP_NAME} \
                  --set image.tag=${IMAGE_TAG} \
                  -n ${NAMESPACE} --create-namespace
                '''
            }
        }

        stage('Rollout Deployment') {
            steps {
                sh '''
                echo "Restarting deployment to pick up new image..."
                oc rollout restart deployment/${APP_NAME} -n ${NAMESPACE}
                '''
            }
        }
    }

    post {
        success {
            echo "Successfully built and deployed face-recognition using OpenShift build"
        }
        failure {
            echo "Build or deploy failed. Check Jenkins logs for details."
        }
    }
}
