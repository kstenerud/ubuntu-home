set -eu

NAME=$1
shift
RELEASE=$1
shift

echo "Building $RELEASE lxc container [$NAME]..."
lxc launch $RELEASE $NAME
until lxc exec $NAME -- ping -c 1 -w 15 8.8.8.8 >/dev/null 2>&1
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
