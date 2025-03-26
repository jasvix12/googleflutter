buildscript {
    repositories {    // O la versión más reciente
    google()
    mavenCentral()
    }


    dependencies {// Ajusta la versión si es necesario
    classpath("com.google.gms:google-services:4.4.2")
    classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")

        // Tu dependencia

    }
    }

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}



val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

