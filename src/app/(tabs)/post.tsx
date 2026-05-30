import { Text, View } from "react-native";
import { appStyles } from "../lib/styles";

export default function Post() {
  const styles = appStyles;
  return (
    <View style={styles.root}>
      <Text style={styles.label}>Post</Text>
    </View>
  );
}
