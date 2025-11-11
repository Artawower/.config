function docker-clean
    docker system prune -a --volumes
    docker system prune -af
    docker builder prune -af
    docker image prune -a -f
    docker system df
end
