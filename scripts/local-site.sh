#!/bin/bash
#---------------------------------------------------------------------
# Description: build local copy of GitHub pages site
#---------------------------------------------------------------------

[ -n "$DEBUG" ] && set -x

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

script_name=${0##*/}

#---------------------------------------------------------------------
# GitHub Pages version of Jekyll
jekyll_image="docker.io/jekyll/jekyll:pages"

site_name="jamesodhunt.github.io"

host="127.0.0.1"
port="4000"

#---------------------------------------------------------------------

die()
{
    msg="$*"
    echo >&2 "ERROR: $msg"
    exit 1
}

info()
{
    str="$*"
    echo "INFO: $str"
}

warn()
{
    str="$*"
    echo >&2 "WARNING: $str"
}

setup()
{
    podman pull "$jekyll_image"
}

# Podman does weird things to file ownership and permissions
# so create a copy of the site.
copy_site()
{
    local cmd="$1"
    local src="$2"
    local site_dir="$2"
    local bundle_dir="$3"

    info "copying site"

    # Start from a clean environment
    if [ "$cmd" = "build" ] || [ "$cmd" = "serve" ]
    then
        local dir
        for dir in "$site_dir" "$bundle_dir"
        do
            [ -z "$dir" ] && die "invalid directory"
            [ "$dir" = "/" ] && die "directory cannot be root"
            echo "$dir" | grep -q ^/tmp || die "directory should be temporary"

            sudo rm -rf "$dir"
        done

        mkdir -p "$site_dir" "$bundle_dir"
    fi

    rsync -auvz --exclude=".git" "$src" "${site_dir}/"

    # XXX: Yes, this *is* required to avoid weird EPERM errors due
    # XXX: to podman using a different user (ns) to "$USER".
    sudo chmod 777 -R "${site_dir}"

    #pushd "$site_dir"
    #sudo rm -f "Gemfile.lock"
    #popd

    info "copyied site"
}

build_container()
{
    local site_dest="$1"
    local bundle_dest="$2"
    local container_jekyll_dir="$3"
    local container_jekyll_site_dir="$4"
    local container_bundle_dir="$5"

    local pkgs=()

    # Required Alpine dependencies
    pkgs+=("build-base")
    pkgs+=("gcc")
    pkgs+=("libc-dev")
    pkgs+=("libxml2-dev")
    pkgs+=("libxslt-dev")
    pkgs+=("linux-headers")
    pkgs+=("make")
    pkgs+=("ruby-dev")

    podman run -it --rm --name jekyll \
        -v "${site_dest}:${container_jekyll_dir}:rw,z" \
        -v "${bundle_dest}:${container_bundle_dir}:rw,z" \
        -w "${container_jekyll_site_dir}" \
        "${jekyll_image}" \
        bash -c "apk --no-cache add --virtual build_deps ${pkgs[*]} && \
        bundle install && \
        bundle exec jekyll build --incremental --drafts --config _config.yml,_config-dev.yml"
}

run_container()
{
    local site_dest="$1"
    local bundle_dest="$2"
    local container_jekyll_dir="$3"
    local container_jekyll_site_dir="$4"
    local container_bundle_dir="$5"

    # XXX: Notes:
    # XXX:
    # XXX: - The port specification - only serve to the specified host!
    # XXX: - The 'bundle install' seems to be required here too!
    podman run -it --rm --name jekyll \
        -v "${site_dest}:${container_jekyll_dir}:rw,z" \
        -v "${bundle_dest}:${container_bundle_dir}:rw,z" \
        -w "${container_jekyll_site_dir}" \
        -p "${host}:${port}:${port}" \
        "${jekyll_image}" \
        bash -c "bundle install && \
        bundle exec jekyll serve \
        --drafts \
        --incremental \
        --config _config.yml,_config-dev.yml \
        --host ${host} \
        --port ${port}"
}

handle_site()
{
    local cmd="$1"
    local src="$2"
    local site_dest="$3"
    local bundle_dest="$4"

    local container_jekyll_dir="/srv/jekyll"
    local container_jekyll_site_dir="${container_jekyll_dir}/$site_name"

    local container_bundle_dir="/usr/local/bundle"

    copy_site "$cmd" "$src" "$site_dest" "$bundle_dest"

    if [ "$cmd" = "build" ] || [ "$cmd" = "serve" ]
    then
        info "building site"

        build_container \
            "${site_dest}" \
            "${bundle_dest}" \
            "${container_jekyll_dir}" \
            "${container_jekyll_site_dir}" \
            "${container_bundle_dir}"

        info "built site"

        [ "$cmd" = "build" ] && return 0
    fi

    info "running site"

    run_container \
        "${site_dest}" \
        "${bundle_dest}" \
        "${container_jekyll_dir}" \
        "${container_jekyll_site_dir}" \
        "${container_bundle_dir}"
}

usage()
{
    cat <<EOT
Usage: $script_name [command]

Description: Build and run GitHub.io site locally.

Commands:

  build    : Only build the site.
  help     : Show this help statement.
  run      : Only run the site (no build).
  serve    : Build and run the site [default].

EOT
}

main()
{
    local src="$PWD"

    local site_dest="/tmp/site"
    local bundle_dest="/tmp/bundle"

    local cmd="${1:-}"

    [ "$cmd" = help ] && usage && exit 0

    [ -z "$cmd" ] && cmd="serve"

    # Validate only
    case "$cmd" in
        build) true ;;  # build only
        run) true ;;    # run only (no build)
        serve) true ;;  # build and run
        *) die "invalid command: '$cmd'" ;;
    esac

    setup

    handle_site "$cmd" "$src" "$site_dest" "$bundle_dest"
}

main "$@"
