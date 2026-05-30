import { useState } from "react";
import {
    Alert,
    Image,
    KeyboardAvoidingView,
    Platform,
    ScrollView,
    Text,
    TextInput,
    TouchableOpacity,
    View,
} from "react-native";
import { appStyles } from "../app/lib/styles";
import { supabase } from "../app/lib/supabase";

export default function Auth() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const styles = appStyles;

  async function signInWithEmail() {
    setLoading(true);
    const { error } = await supabase.auth.signInWithPassword({
      email: email,
      password: password,
    });

    if (error) Alert.alert(error.message);
    setLoading(false);
  }

  async function signUpWithEmail() {
    setLoading(true);
    const { error } = await supabase.auth.signUp({
      email: email,
      password: password,
      options: {
        emailRedirectTo: "questlogic://", // your app scheme
      },
    });

    if (error) Alert.alert(error.message);
    else Alert.alert("Check your email for the confirmation link!");
    setLoading(false);
  }

  return (
    <KeyboardAvoidingView
      style={styles.root}
      behavior={Platform.OS === "ios" ? "padding" : "height"}
    >
      <ScrollView
        contentContainerStyle={styles.container}
        keyboardShouldPersistTaps="handled"
      >
        {/* Logo / Image */}
        <View style={styles.imageContainer}>
          <Image
            source={{
              uri: "https://www.image2url.com/r2/default/images/1779961505081-b5bdec8c-5dcd-477d-a779-eabbfeee7790.png",
            }}
            style={styles.logo}
            resizeMode="contain"
          />
        </View>

        <View>
          <View style={[styles.verticallySpaced, styles.mt20]}>
            <Text style={styles.label}>Email</Text>
            <TextInput
              onChangeText={(text) => setEmail(text)}
              value={email}
              placeholder="email@address.com"
              autoCapitalize="none"
              style={styles.input}
            />
          </View>
          <View style={styles.verticallySpaced}>
            <Text style={styles.label}>Password</Text>
            <TextInput
              onChangeText={(text) => setPassword(text)}
              value={password}
              secureTextEntry={true}
              placeholder="Password"
              autoCapitalize="none"
              style={styles.input}
            />
          </View>
          <View style={[styles.verticallySpaced, styles.mt20]}>
            <TouchableOpacity
              style={[styles.primaryButton, loading && styles.buttonDisabled]}
              onPress={() => signInWithEmail()}
              disabled={loading}
            >
              <Text style={styles.buttonText}>Sign in</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.verticallySpaced}>
            <TouchableOpacity
              style={[styles.secondaryButton, loading && styles.buttonDisabled]}
              onPress={() => signUpWithEmail()}
              disabled={loading}
            >
              <Text style={styles.buttonText}>Sign up</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
