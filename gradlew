#!/usr/bin/env sh

##############################################################################
##
##  Gradle start up script for UN*X
##
##############################################################################

# Set local scope for the variables with windows NT shell
if [ -n "$CYGWIN" ] || [ -n "$MINGW" ] || [ -n "$MSYS" ]; then
    APP_BASE_NAME=`basename "$0"`
else
    APP_BASE_NAME=$(basename "$0")
fi

APP_HOME=$(cd "$(dirname "$0")" && pwd)

if [ -z "$JAVA_HOME" ] ; then
    if [ -r "$APP_HOME/gradle/wrapper/gradle-wrapper.jar" ]; then
        JAVACMD="java"
    else
        JAVACMD="javac"
        if [ ! -x "$JAVACMD" ] ; then
            JAVACMD="java"
        fi
    fi
else
    JAVACMD="$JAVA_HOME/bin/java"
fi

if [ ! -x "$JAVACMD" ] ; then
    echo "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME"
    echo "Please set the JAVA_HOME variable in your environment to match the"
    echo "location of your Java installation."
    exit 1
fi

CLASSPATH="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"

# Determine the Java command to use to start the JVM.
if [ "$JAVA_HOME" != "" ] && [ -x "$JAVA_HOME/bin/java" ]; then
    # IBM's JDK on AIX uses strange locations for the executables
    JAVACMD="$JAVA_HOME/bin/java"
else
    JAVACMD="java"
fi

# Increase the maximum file descriptors if we can.
if [ "$cygwin" = "true" -o "$darwin" = "true" -o "$nonstop" = "true" ]; then
    MAX_FD="maximum"
    ulimit -n $MAX_FD 2>/dev/null || true
fi

# For Darwin, add options to specify how the application appears in the dock
if [ "$darwin" = "true" ]; then
    GRADLE_OPTS="$GRADLE_OPTS -Xdock:name=Gradle -Xdock:icon="$APP_HOME"/gradle/wrapper/gradle-wrapper.jar"
fi

# For Cygwin, switch paths to Windows format before running java
if [ "$cygwin" = "true" ]; then
    APP_HOME=`cygpath --path --mixed "$APP_HOME"`
    CLASSPATH=`cygpath --path --mixed "$CLASSPATH"`
    JAVACMD=`cygpath --unix "$JAVACMD"`

    # We build the pattern for arguments to be converted via cygpath
    ROOTDIRSRAW=`find -L / -maxdepth 1 -mindepth 1 -type d 2>/dev/null`
    SEP=""
    for dir in $ROOTDIRSRAW ; do
        ROOTDIRS="$ROOTDIRS$SEP$dir"
        SEP=":"
    done
    OURCYGPATTERN="(^($ROOTDIRS))"
    # Add a user-defined pattern to the cygpath arguments
    if [ "$GRADLE_CYGPATTERN" != "" ]; then
        OURCYGPATTERN="$OURCYGPATTERN|($GRADLE_CYGPATTERN)"
    fi
    # Now convert the arguments - kludge to limit ourselves to /bin/sh
    i=0
    for arg in "$@" ; do
        CHECK=`echo "$arg"|egrep -c "$OURCYGPATTERN" -`
        CHECK2=`echo "$arg"|egrep -c "^-"`                                 ### Determine if an option

        if [ $CHECK -ne 0 ] && [ $CHECK2 -eq 0 ]; then                        ### Added a condition
            eval "arg$i=`cygpath --path --ignore --mixed "$arg"`"
        else
            eval "arg$i='$arg'"
        fi
        i=$((i+1))
    done
    case $i in
        (0) set -- ;;                                             ### Empty set, avoid syntax error
        (1) set -- "$arg0" ;;                                     ### One argument
        (2) set -- "$arg0" "$arg1" ;;                             ### Two arguments
        (3) set -- "$arg0" "$arg1" "$arg2" ;;                     ### Three arguments
        (4) set -- "$arg0" "$arg1" "$arg2" "$arg3" ;;             ### Four arguments
        (5) set -- "$arg0" "$arg1" "$arg2" "$arg3" "$arg4" ;;         ### Five arguments
        (6) set -- "$arg0" "$arg1" "$arg2" "$arg3" "$arg4" "$arg5" ;;     ### Six arguments
        (7) set -- "$arg0" "$arg1" "$arg2" "$arg3" "$arg4" "$arg5" "$arg6" ;; ### Seven arguments
        (8) set -- "$arg0" "$arg1" "$arg2" "$arg3" "$arg4" "$arg5" "$arg6" "$arg7" ;; ### Eight arguments
        (9) set -- "$arg0" "$arg1" "$arg2" "$arg3" "$arg4" "$arg5" "$arg6" "$arg7" "$arg8" ;; ### Nine arguments
        (*) set -- "$arg0" "$arg1" "$arg2" "$arg3" "$arg4" "$arg5" "$arg6" "$arg7" "$arg8" "${@:10}" ;; ### Ten or more arguments
    esac
fi

# Split up the JVM_OPTS And GRADLE_OPTS values into an array, following the shell quoting and substitution rules
function splitJvmOpts() {
    JVM_OPTS=()
    local IFS=$'\n'
    for opt in $(echo "$*" | grep -E '(^|\s)-' | sed -E 's/(^|\s)-([^\s]+)/-\2/g'); do
        JVM_OPTS+=(["$opt"])
    done
}

splitJvmOpts $JAVA_OPTS $GRADLE_OPTS

# Collect all arguments for the java command, following the shell quoting and substitution rules
function collectArgs() {
    local args=()
    local IFS=$'\n'
    for arg in "$@"; do
        if [ "$arg" = "--debug" ]; then
            set -- "${@:1:$(($#-1))}"
            args+=(["-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005"])
        elif [ "$arg" = "--no-daemon" ]; then
            set -- "${@:1:$(($#-1))}"
            args+=(["-Dorg.gradle.daemon=false"])
        elif [ "$arg" = "--daemon" ]; then
            set -- "${@:1:$(($#-1))}"
            args+=(["-Dorg.gradle.daemon=true"])
        elif [ "$arg" = "--stop" ]; then
            set -- "${@:1:$(($#-1))}"
            args+=(["-Dorg.gradle.stop=true"])
        elif [ "$arg" = "--status" ]; then
            set -- "${@:1:$(($#-1))}"
            args+=(["-Dorg.gradle.status=true"])
        else
            args+=(["$arg"])
        fi
    done
    echo "${args[@]}"
}

# by default we should run in the current directory
if [ -z "$GRADLE_HOME" ]; then
    GRADLE_HOME="$APP_HOME"
fi

# Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
DEFAULT_JVM_OPTS="-Xmx1024m -Dfile.encoding=UTF-8"

# Collect all arguments
ARGS=$(collectArgs "$@")

# Execute Gradle
"$JAVACMD" "${JVM_OPTS[@]}" "$DEFAULT_JVM_OPTS" -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$ARGS"
