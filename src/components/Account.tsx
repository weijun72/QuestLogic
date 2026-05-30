import { useEffect, useState } from "react";
import {
    Alert,
    ScrollView,
    Text,
    TextInput,
    TouchableOpacity,
    View,
} from "react-native";
import { appStyles } from "../app/lib/styles";
import { supabase } from "../app/lib/supabase";
import Avatar from "./Avatar";

export default function Account({
  userId,
  email,
}: {
  userId: string;
  email?: string;
}) {
  const [loading, setLoading] = useState(true);
  const [username, setUsername] = useState("");
  const [bio, setBio] = useState("");
  const [skillsToTeach, setSkillsToTeach] = useState("");
  const [skillsToLearn, setSkillsToLearn] = useState("");
  const [avatarUrl, setAvatarUrl] = useState("");
  const styles = appStyles;

  useEffect(() => {
    if (userId) getProfile();
  }, [userId]);

  async function getProfile() {
    try {
      setLoading(true);

      let { data, error, status } = await supabase
        .from("profiles")
        .select(`username, bio, skillsToTeach, skillsToLearn, avatar_url`)
        .eq("id", userId)
        .single();
      if (error && status !== 406) {
        throw error;
      }

      if (data) {
        setUsername(data.username);
        setBio(data.bio);
        setSkillsToTeach(data.skillsToTeach);
        setSkillsToLearn(data.skillsToLearn);
        setAvatarUrl(data.avatar_url);
      }
    } catch (error) {
      if (error instanceof Error) {
        Alert.alert(error.message);
      }
    } finally {
      setLoading(false);
    }
  }

  async function updateProfile({
    username,
    bio,
    skillsToTeach,
    skillsToLearn,
    avatar_url,
  }: {
    username: string;
    bio: string;
    skillsToTeach: string;
    skillsToLearn: string;
    avatar_url: string;
  }) {
    try {
      setLoading(true);

      const updates = {
        id: userId,
        username,
        bio,
        skillsToTeach,
        skillsToLearn,
        avatar_url,
        updated_at: new Date(),
      };

      let { error } = await supabase.from("profiles").upsert(updates);

      if (error) {
        throw error;
      }
    } catch (error: any) {
      Alert.alert(error.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <View style={styles.root}>
      <ScrollView style={{ flex: 1 }} contentContainerStyle={styles.container}>
        <View>
          <Avatar
            size={200}
            url={avatarUrl}
            onUpload={(url: string) => {
              console.log("Uploaded path:", url);
              setAvatarUrl(url);
              updateProfile({
                username,
                bio,
                skillsToTeach,
                skillsToLearn,
                avatar_url: url,
              });
            }}
          />
        </View>
        <View style={[styles.verticallySpaced, styles.mt20]}>
          <Text style={styles.label}>Email</Text>
          <TextInput
            value={email ?? ""}
            editable={false}
            selectTextOnFocus={false}
            style={[styles.input, styles.inputDisabled]}
          />
        </View>
        <View style={styles.verticallySpaced}>
          <Text style={styles.label}>Username</Text>
          <TextInput
            value={username || ""}
            onChangeText={(text) => setUsername(text)}
            style={styles.input}
          />
        </View>
        <View style={styles.verticallySpaced}>
          <Text style={styles.label}>Bio</Text>
          <TextInput
            value={bio || ""}
            onChangeText={(text) => setBio(text)}
            style={styles.input}
          />
        </View>
        <View style={styles.verticallySpaced}>
          <Text style={styles.label}>Skills to Teach</Text>
          <TextInput
            value={skillsToTeach || ""}
            onChangeText={(text) => setSkillsToTeach(text)}
            style={styles.input}
          />
        </View>
        <View style={styles.verticallySpaced}>
          <Text style={styles.label}>Skills to Learn</Text>
          <TextInput
            value={skillsToLearn || ""}
            onChangeText={(text) => setSkillsToLearn(text)}
            style={styles.input}
          />
        </View>

        <View style={[styles.verticallySpaced, styles.mt20]}>
          <TouchableOpacity
            style={[styles.primaryButton, loading && styles.buttonDisabled]}
            onPress={() =>
              updateProfile({
                username,
                bio,
                skillsToTeach,
                skillsToLearn,
                avatar_url: avatarUrl,
              })
            }
            disabled={loading}
          >
            <Text style={styles.buttonText}>
              {loading ? "Loading ..." : "Update"}
            </Text>
          </TouchableOpacity>
        </View>

        <View style={styles.verticallySpaced}>
          <TouchableOpacity
            style={styles.secondaryButton}
            onPress={() => supabase.auth.signOut()}
          >
            <Text style={styles.buttonText}>Sign Out!</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </View>
  );
}
