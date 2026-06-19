import com.android.build.gradle.LibraryExtension

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

// AGP 8+ requires every Android module to define a namespace.
// Some older Flutter plugins (like uni_links 0.5.1) don't set it, causing builds to fail.
subprojects {
    plugins.withId("com.android.library") {
        if (project.name == "uni_links") {
            extensions.configure<LibraryExtension>("android") {
                namespace = "com.ifstatic.rotijugaad.uni_links"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
