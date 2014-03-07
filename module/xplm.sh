# vim: tw=0:ts=4:sw=4:et:ft=bash

:<<[core:docstring]
The eXternal Programming (scripting) Language Module manager.

This modules handles Python, Ruby, and Perl modules in site's sandboxed virtual
environment.
[core:docstring]

#. XPLM -={
core:import util

declare -gA g_PROLANG
g_PROLANG=(
    [rb]=ruby
    [py]=python
    [pl]=perl
)

declare -gA g_PROLANG_VERSION
g_PROLANG_VERSION=(
    [rb]=${RBENV_VERSION?}
    [py]=${PYENV_VERSION?}
    [pl]=${PLENV_VERSION?}
)

declare -gA g_PROLANG_ROOT
g_PROLANG_ROOT=(
    [rb]=${RBENV_ROOT?}
    [py]=${PYENV_ROOT?}
    [pl]=${PLENV_ROOT?}
)

#. ::xplm:loadvirtenv -={
function ::xplm:loadvirtenv() {
    local -i e=${CODE_FAILURE?}

    if [ $# -eq 1 ]; then
        case $1 in
            rb)
                export RBENV_GEMSET_FILE="${RBENV_ROOT?}/.rbenv-gemsets"
            ;;
            pl)
                export PERL_CPANM_HOME="${PLENV_ROOT?}/.cpanm"
                export PERL_CPANM_OPT="--prompt --reinstall"
            ;;
        esac

        case $1 in
            rb|py|pl)
                local plid="${1}"
                local virtenv="${plid}env"
                local interpreter=${SITE_USER_VAR}/${virtenv}/shims/${g_PROLANG[${plid}]}
                if [ -x "${interpreter}" ]; then
                    eval "$(${virtenv} init -)"
                    ${virtenv} rehash
                    ${virtenv} shell ${g_PROLANG_VERSION[${plid}]}
                    e=$?
                #else
                #    theme ERR "Please install ${plid} first via \`xplm install ${plid}' first"
                fi
            ;;
            *)
                core:raise EXCEPTION_BAD_FN_CALL
            ;;
        esac
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}
#. }=-
#.  :xplm:requires -={
function :xplm:requires() {
    local -i e=${CODE_FAILURE?}

    if [ $# -eq 2 ]; then
        local plid="${1}"
        local required="${2}"
        case ${plid} in
            py)
                if ::xplm:loadvirtenv ${plid}; then
                    python -c "import ${required}" 2>/dev/null
                    [ $? -ne 0 ] || e=${CODE_SUCCESS?}
                fi
            ;;
            rb)
                if ::xplm:loadvirtenv ${plid}; then
                    ruby -e "require '${required}'" 2>/dev/null
                    [ $? -ne 0 ] || e=${CODE_SUCCESS?}
                fi
            ;;
            pl)
                if ::xplm:loadvirtenv ${plid}; then
                    perl -M${required} -e ';' 2>/dev/null
                    [ $? -ne 0 ] || e=${CODE_SUCCESS?}
                fi
            ;;
        esac
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}
#. }=-
#.   xplm:list -={
function :xplm:list() {
    local -i e=${CODE_FAILURE?}

    if [ $# -eq 1 ]; then
        local plid="${1}"
        case ${plid} in
            py)
                if ::xplm:loadvirtenv ${plid}; then
                    pip list | sed 's/^/py /'
                    e=${PIPESTATUS[0]}
                fi
            ;;
            rb)
                if ::xplm:loadvirtenv ${plid}; then
                    gem list --local | sed 's/^/rb /'
                    e=${PIPESTATUS[0]}
                fi
            ;;
            pl)
                if ::xplm:loadvirtenv ${plid}; then
                    perl <(
cat <<!
#!/usr/bin/env perl -w
use ExtUtils::Installed;
my \$installed = ExtUtils::Installed->new();
my @modules = \$installed->modules();
foreach \$module (@modules) {
    printf("%s (%s)\n", \$module, \$installed->version(\$module));
}
!
) | sed 's/^/pl /'
                    e=${PIPESTATUS[0]}
                fi
            ;;
        esac
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}

function xplm:list:usage() { echo "[<plid>]"; }
function xplm:list() {
    local -i e=${CODE_DEFAULT?}

    if [ $# -le 1 ]; then
        local -A prolangs=( [py]=0 [pl]=0 [rb]=0 )
        for plid in "${@}"; do
            case "${plid}" in
                py) prolangs[${plid}]=1;;
                pl) prolangs[${plid}]=1;;
                rb) prolangs[${plid}]=1;;
                *) e=${CODE_FAILURE?};;
            esac
        done

        if [ $e -ne ${CODE_FAILURE?} ]; then
            for plid in ${!prolangs[@]}; do
                if [[ $# -eq 0 || ${prolangs[${plid}]} -eq 1 ]]; then
                    :xplm:list ${plid}
                    e=$?
                fi
            done
        else
            theme HAS_FAILED "Unknown/unsupported language ${plid}"
        fi
    fi

    return $e
}
#. }=-
#.   xplm:install -={
function :xplm:install() {
    local -i e=${CODE_FAILURE?}

    if [ $# -gt 1 ]; then
        local plid="${1}"
        case ${plid} in
            py)
                if ::xplm:loadvirtenv ${plid}; then
                    pip install --upgrade -q "${@:2}"
                    e=$?
                fi
            ;;
            rb)
                if ::xplm:loadvirtenv ${plid}; then
                    gem install -q "${@:2}"
                    e=$?
                fi
            ;;
            pl)
                if ::xplm:loadvirtenv ${plid}; then
                    cpanm ${@:2}
                fi
            ;;
        esac
    elif [ $# -eq 1 ]; then
        #. This is a lazy-installer as well as an initializer for the particular
        #. virtual environment requested; i.e., the first time it is called, it
        #. will install the language interpreter (ruby, python, perl) via rbenv,
        #. pyenv, plenv respectively.

        local plid="${1}"
        local virtenv="${plid}env"
        local interpreter=${SITE_USER_VAR}/${virtenv}/shims/${g_PROLANG[${plid}]}

        if ! ::xplm:loadvirtenv ${plid}; then
            #. Before Install -={
            case ${plid} in
                rb)
                    echo .gems > ${RBENV_ROOT?}/.rbenv-gemsets
                ;;
                pl)
                    mkdir -p ${PERL_CPANM_HOME?}
                ;;
            esac
            #. }=-

            case ${plid} in
                rb|py|pl)
                    ${virtenv} install ${g_PROLANG_VERSION[${plid}]} >${SITE_USER}/var/log/${virtenv}.log 2>&1
                    ${virtenv} rehash
                    e=$?
                ;;
                *) core:raise EXCEPTION_BAD_FN_CALL ;;
            esac

            #. After Install -={
            if [ $e -eq ${CODE_SUCCESS?} ]; then
                eval "$(${virtenv} init -)"
                case ${plid} in
                    pl) plenv install-cpanm >${SITE_USER}/var/log/${virtenv}-cpanm.log 2>&1;;
                esac
            fi
            #. }=-
        else
            e=${CODE_SUCCESS?}
        fi
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}
function xplm:install:usage() { echo "<plid> [<pkg> [<pkg> [...]]]"; }
function xplm:install() {
    local -i e=${CODE_DEFAULT?}

    if [ $# -gt 1 ]; then
        local plid="$1"
        case "${plid}" in
            py|pl|rb)
                :xplm:install ${plid} "${@:2}"
                e=$?
            ;;
            *)
                theme HAS_FAILED "Unknown/unsupported language ${plid}"
                e=${CODE_FAILURE?}
            ;;
        esac
    elif [ $# -eq 1 ]; then
        local plid="${1}"
        case ${plid} in
            rb|py|pl)
                cpf "Installing %{y:%s}: %{r:%s-%s}..."\
                    "${plid}"\
                    "${g_PROLANG[${plid}]}" "${g_PROLANG_VERSION[${plid}]}"
                :xplm:install ${plid}
                e=$?
                theme HAS_AUTOED $e
            ;;
        esac
    fi

    return $e
}
#. }=-
#.   xplm:shell -={
function :xplm:shell() {
    local -i e=${CODE_FAILURE?}

    if [ $# -eq 1 ]; then
        local plid="${1}"
        case ${plid} in
            rb|py|pl)
                if ::xplm:loadvirtenv ${plid}; then
                    echo "Ctrl-D to exit environment"
                    cd ${g_PROLANG_ROOT[${plid}]}
                    bash --rcfile <(
                        cat <<!VIRTENV
                        unset PROMPT_COMMAND
                        export PS1="site:${plid}> "
!VIRTENV
                    ) -i
                    e=$?
                fi
            ;;
        esac
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}
function xplm:shell:usage() { echo "<plid>"; }
function xplm:shell() {
    local -i e=${CODE_DEFAULT?}

    if [ $# -eq 1 ]; then
        local plid="$1"
        case "${plid}" in
            py|pl|rb)
                :xplm:shell ${plid} "${@:2}"
                e=$?
            ;;
            *)
                theme HAS_FAILED "Unknown/unsupported language ${plid}"
                e=${CODE_FAILURE?}
            ;;
        esac
    fi

    return $e
}
#. }=-
#.   xplm:search -={
function :xplm:search() {
    local -i e=${CODE_FAILURE?}

    if [ $# -gt 1 ]; then
        local plid="${1}"
        case ${plid} in
            py)
                if ::xplm:loadvirtenv ${plid}; then
                    pip search "${@:2}" | cat
                    e=${PIPESTATUS[0]}
                fi
            ;;
            rb)
                if ::xplm:loadvirtenv ${plid}; then
                    gem search "${@:2}" | cat
                    e=${PIPESTATUS[0]}
                fi
            ;;
            pl)
                if ::xplm:loadvirtenv ${plid}; then
                    e=${CODE_NOTIMPL?}
                fi
            ;;
        esac
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}

function xplm:search:usage() { echo "<plid> <search-str>"; }
function xplm:search() {
    local -i e=${CODE_DEFAULT?}

    if [ $# -gt 1 ]; then
        local plid="$1"
        case "${plid}" in
            py|pl|rb)
                :xplm:search ${plid} "${@:2}"
                e=$?
            ;;
            *)
                theme HAS_FAILED "Unknown/unsupported language ${plid}"
                e=${CODE_FAILURE?}
            ;;
        esac
    fi

    return $e
}
#. }=-
#.   xplm:repl -={
function :xplm:repl() {
    local -i e=${CODE_FAILURE?}

    if [ $# -eq 1 ]; then
        local plid="${1}"
        case ${plid} in
            py)
                ::xplm:loadvirtenv ${plid} && python
                e=$?
            ;;
            rb)
                ::xplm:loadvirtenv ${plid} && irb
                e=$?
            ;;
            pl)
                e=${CODE_NOTIMPL?}
            ;;
        esac
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}
function xplm:repl:usage() { echo "<plid>"; }
function xplm:repl() {
    local -i e=${CODE_DEFAULT?}

    if [ $# -eq 1 ]; then
        local plid="$1"
        case "${plid}" in
            py|pl|rb)
                :xplm:repl ${plid} "${@:2}"
                e=$?
            ;;
            *)
                theme HAS_FAILED "Unknown/unsupported language ${plid}"
                e=${CODE_FAILURE?}
            ;;
        esac
    fi

    return $e
}
#. }=-
#. }=-