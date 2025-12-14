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
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Use an actual Android Gradle Plugin version that matches your Gradle wrapper.
        // Common stable value: 7.4.2 — update if your project requires a different one.
        classpath("com.android.tools.build:gradle:7.4.2")
        // Add google services plugin for Firebase
        classpath("com.google.gms:google-services:4.3.15")
    }
}
