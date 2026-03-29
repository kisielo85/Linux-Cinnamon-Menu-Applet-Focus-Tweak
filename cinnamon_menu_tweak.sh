#!/bin/sh
FILE_PATH=$(find /usr/share/cinnamon -name "popupMenu.js")
echo "$FILE_PATH"
BACKUP_PATH="${FILE_PATH%.js}_backup.js"

if [ ! -f "$BACKUP_PATH" ]; then
  echo "saving backup to: $BACKUP_PATH"
  sudo cp $FILE_PATH $BACKUP_PATH
else 
  echo "backup arleady exists"
fi

line_num=0
found=0
depth=0
error=0

# find the last line containing "return" in _onEventCapture()
# and swap it to "return false"
while IFS= read -r line; do
  line_num=$((line_num + 1))

  if [ $found -eq 0 ]; then
    case "$line" in
      *'_onEventCapture(actor, event) {'*)
        found=1
        depth=1
        ;;
    esac
    continue
  fi

  case "$line" in
    *'{'*) depth=$((depth + 1)) ;;
  esac
  case "$line" in
    *'}'*) depth=$((depth - 1)) ;;
  esac

  if [ $depth -eq 0 ]; then
    break
  fi

done < "$FILE_PATH"

while [ $line_num -gt 0 ]; do
  line=$(sed -n "${line_num}p" "$FILE_PATH")

  case "$line" in
    *'return'*)
      sudo sed -i "${line_num}s/.*/        return false; \/\/changed from: true/" "$FILE_PATH"
      break
      ;;
  esac

  line_num=$((line_num - 1))
done

# swap "this._eventIsOnActiveMenu(event)"" to "event.get_source().get_style_class_name != undefined"
sudo sed -i 's/let activeMenuContains = this._eventIsOnActiveMenu(event);/let activeMenuContains = event.get_source().get_style_class_name != undefined; \/\/changed from: this._eventIsOnActiveMenu(event)/' "$FILE_PATH"

if [ $? -ne 0 ]; then
    echo "an error occured, exiting script."
    exit
fi

echo "\nfile patched, restarting cinnamon in 5.."
for i in 4 3 2 1; do sleep 1 && echo $i..; done

cinnamon --replace >/dev/null 2>&1 &

echo "done."
echo "\nto revert changes paste this command:"
echo "\nsudo cp $BACKUP_PATH $FILE_PATH && cinnamon --replace >/dev/null 2>&1 &"