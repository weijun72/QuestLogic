import { Pressable, StyleSheet, Text, View } from "react-native";

export default function Index() {
  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Welcome back</Text>

        <Text style={styles.subtitle}>
          Start your journey with a quick login or create a new account.
        </Text>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Get started</Text>
          <Text style={styles.cardText}>
            Access your account or register to save your progress.
          </Text>

          <Pressable style={styles.primaryButton}>
            <Text style={styles.buttonText}>Login</Text>
          </Pressable>

          <Pressable style={styles.secondaryButton}>
            <Text style={styles.buttonText}>Register</Text>
          </Pressable>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: 24,
    backgroundColor: "#f8fafc",
  },
  content: {
    width: "100%",
    maxWidth: 420,
    gap: 18,
  },
  title: {
    fontSize: 32,
    fontWeight: "700",
    textAlign: "center",
    color: "#0f172a",
  },
  subtitle: {
    fontSize: 16,
    lineHeight: 24,
    textAlign: "center",
    color: "#475569",
  },
  card: {
    backgroundColor: "#ffffff",
    borderRadius: 24,
    padding: 20,
    gap: 14,
    shadowColor: "#000",
    shadowOpacity: 0.08,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 4 },
    elevation: 3,
  },
  cardTitle: {
    fontSize: 20,
    fontWeight: "700",
    color: "#0f172a",
  },
  cardText: {
    fontSize: 15,
    lineHeight: 22,
    color: "#334155",
  },
  primaryButton: {
    backgroundColor: "#2563eb",
    paddingVertical: 14,
    borderRadius: 14,
    alignItems: "center",
  },
  secondaryButton: {
    backgroundColor: "#0f172a",
    paddingVertical: 14,
    borderRadius: 14,
    alignItems: "center",
  },
  buttonText: {
    color: "#ffffff",
    fontSize: 16,
    fontWeight: "700",
  },
});
