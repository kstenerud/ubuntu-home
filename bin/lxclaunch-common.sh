set -eu

NAME=$1
shift
RELEASE=$1
shift

echo "Building $RELEASE lxc container [$NAME]..."
lxc launch $RELEASE $NAME
lxc exec $NAME dhclient
until lxc exec $NAME -- route -n |grep UG >/dev/null
do
	echo "Waiting for network..."
	sleep 1
done

lxc exec $NAME -- apt update
lxc exec $NAME -- apt dist-upgrade -y
lxc exec $NAME -- apt autoremove -y
lxc exec $NAME -- apt install -y $@

echo "Entering bash for $RELEASE lxc container [$NAME]"
lxc exec $NAME -- bash
