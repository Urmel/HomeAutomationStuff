#
# Ensure correct rights for openhab folders

echo Resetting ACLs for /openhab/userdata ...
chown -R openhab:openhab /openhab/userdata
find /openhab/userdata -type d -exec chmod 2770 {} \;
find /openhab/userdata -type f -exec chmod 660 {} \;

echo Resetting ACLs for /venvs/graalpy ...
chown -R openhab:openhab /venvs/graalpy
find /venvs/graalpy -type d -exec chmod 2770 {} \;
find /venvs/graalpy -type f -exec chmod 660 {} \;
