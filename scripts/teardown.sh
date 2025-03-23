empty_and_delete_bucket() {
  local bucket=$1
  echo "Checking if $bucket exists..."
  if aws s3 ls "s3://$bucket" 2>/dev/null; then
    echo "Checking if $bucket has objects..."
    OBJECT_COUNT=$(aws s3api list-objects-v2 --bucket "$bucket" --query 'Contents | length(@)' --output text 2>/dev/null || echo 0)
    if [ "$OBJECT_COUNT" -gt 0 ]; then
      echo "$bucket has $OBJECT_COUNT objects, emptying it..."
      aws s3 rm "s3://$bucket" --recursive || { echo "Failed to empty $bucket"; exit 1; }
      ATTEMPTS=20
      DELAY=5
      for ((i=1; i<=$ATTEMPTS; i++)); do
        OBJECT_COUNT=$(aws s3api list-objects-v2 --bucket "$bucket" --query 'Contents | length(@)' --output text 2>/dev/null || echo 0)
        if [ "$OBJECT_COUNT" -gt 0 ]; then
          echo "$bucket still has $OBJECT_COUNT objects, waiting $DELAY seconds (attempt $i/$ATTEMPTS)..."
          sleep $DELAY
        else
          echo "$bucket is now empty"
          break
        fi
      done
      if [ $i -gt $ATTEMPTS ]; then
        echo "Error: $bucket still has objects after $ATTEMPTS attempts"
        exit 1
      fi
    else
      echo "$bucket is already empty"
    fi
    echo "Deleting $bucket..."
    aws s3 rb "s3://$bucket" --force || { echo "Failed to delete $bucket"; exit 1; }
  else
    echo "$bucket does not exist, skipping deletion"
  fi
  ATTEMPTS=20
  DELAY=5
  for ((i=1; i<=$ATTEMPTS; i++)); do
    if aws s3 ls "s3://$bucket" 2>/dev/null; then
      echo "$bucket still exists, waiting $DELAY seconds (attempt $i/$ATTEMPTS)..."
      sleep $DELAY
    else
      echo "$bucket successfully deleted"
      break
    fi
  done
  if [ $i -gt $ATTEMPTS ]; then
    echo "Error: $bucket still exists after $ATTEMPTS attempts"
    exit 1
  fi
}

export -f empty_and_delete_bucket