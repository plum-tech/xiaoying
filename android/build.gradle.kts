import com.android.build.gradle.BaseExtension
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    // fix https://github.com/jonataslaw/VideoCompress/issues/255
    afterEvaluate {
        if (hasProperty("kotlin")) {
            tasks.withType<KotlinCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(JvmTarget.JVM_1_8)
                }
            }
        }
    }
}

allprojects {
    afterEvaluate {
        if (hasProperty("android")) {
            extensions.configure<BaseExtension>("android") {
                if (namespace == null) {
                    namespace = project.group.toString()
                }
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_1_8
                    targetCompatibility = JavaVersion.VERSION_1_8
                }
            }
        }
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(name)
    layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

configurations.all {
    resolutionStrategy {
        force("androidx.core:core:1.6.0")
        force("androidx.core:core-ktx:1.6.0")
    }
}
