String trimToLast(int trimmedLength, String trimString) {
  return (trimString == null || trimString.length <= trimmedLength)
      ? trimString
      : '...${trimString.substring(trimString.length - trimmedLength)}';
}
