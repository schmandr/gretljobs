def dbUriSogis = ''
def dbCredentialNameSogis = ''
def ftpServerZivilschutz = ''
def ftpCredentialNameZivilschutz = ''
def gretljobsRepo = ''

node("master") {
    dbUriSogis = "${env.DB_URI_SOGIS}"
    dbCredentialNameSogis = "${DB_CREDENTIAL_GRETL}"
    ftpServerZivilschutz = "${env.FTP_SERVER_ZIVILSCHUTZ}"
    ftpCredentialNameZivilschutz = "${FTP_CREDENTIAL_ZIVILSCHUTZ}"
    gretljobsRepo = "${env.GRETL_JOB_REPO_URL}"
}

node ("gretl") {
    try {
        gitBranch = "${params.BRANCH ?: 'master'}"
        git url: "${gretljobsRepo}", branch: gitBranch
        dir(env.JOB_BASE_NAME) {
            withCredentials([usernamePassword(credentialsId: "${dbCredentialNameSogis}", usernameVariable: 'dbUserSogis', passwordVariable: 'dbPwdSogis'), usernamePassword(credentialsId: "${ftpCredentialNameZivilschutz}", usernameVariable: 'ftpUserZivilschutz', passwordVariable: 'ftpPwdZivilschutz')]) {
                sh "gradle --init-script /home/gradle/init.gradle -PdbUriSogis='${dbUriSogis}' -PdbUserSogis='${dbUserSogis}' -PdbPwdSogis='${dbPwdSogis}' -PftpServerZivilschutz='${ftpServerZivilschutz}' -PftpUserZivilschutz='${ftpUserZivilschutz}' -PftpPwdZivilschutz='${ftpPwdZivilschutz}'"
            }
        }
    }
    catch (e) {
        echo 'Job failed'
        emailext (
                to: '${DEFAULT_RECIPIENTS}',
                recipientProviders: [requestor()],
                subject: "FAILED: Job ${env.JOB_NAME} ${env.BUILD_DISPLAY_NAME}",
                body: "FAILED: Job ${env.JOB_NAME} ${env.BUILD_DISPLAY_NAME}. Check console output at ${env.BUILD_URL}"
        )
        throw e
    }
}
