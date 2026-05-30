import { StyleSheet } from "react-native";

export const appStyles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: "#fff4e9",
    flexGrow: 1,
  },
  container: {
    marginTop: 40,
    padding: 12,
    flexGrow: 1,
  },
  imageContainer: {
    width: "100%",
    height: 110,
    borderRadius: 55,
    backgroundColor: "#fff4e9",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 10,
    elevation: 5,
  },
  verticallySpaced: {
    paddingTop: 4,
    paddingBottom: 4,
    alignSelf: "stretch",
  },
  mt20: {
    marginTop: 20,
  },
  logo: {
    width: 400,
    height: 400,
  },
  label: {
    fontSize: 16,
    fontWeight: "600",
    color: "#86939e",
    marginBottom: 6,
  },
  input: {
    borderWidth: 1,
    borderColor: "#86939e",
    borderRadius: 4,
    padding: 12,
    fontSize: 16,
  },
  inputDisabled: {
    backgroundColor: "#f2f2f2",
    borderColor: "#d1d1d1",
    color: "#9e9e9e",
  },
  primaryButton: {
    backgroundColor: "#6b5a48",
    borderRadius: 4,
    padding: 12,
    alignItems: "center",
  },
  secondaryButton: {
    backgroundColor: "#879183",
    borderRadius: 4,
    padding: 12,
    alignItems: "center",
  },
  buttonDisabled: {
    opacity: 0.5,
  },
  buttonText: {
    color: "#e7d8c9",
    fontSize: 16,
    fontWeight: "600",
  },
  avatarContainer: {
    alignItems: "center",
    justifyContent: "center",
    marginTop: 20,
  },
  avatar: {
    borderRadius: 5,
    overflow: "hidden",
    marginBottom: 20,
  },
  image: {
    resizeMode: "cover",
    paddingTop: 0,
  },
  noImage: {
    backgroundColor: "#333",
    borderWidth: 1,
    borderStyle: "solid",
    borderColor: "rgb(200, 200, 200)",
    borderRadius: 5,
  },
});
