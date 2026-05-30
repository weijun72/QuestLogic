import * as Linking from "expo-linking";
import { useRouter } from "expo-router";
import { useEffect } from "react";
import { View } from "react-native";
import Auth from "../components/Auth";
import { supabase } from "./lib/supabase";

export default function Index() {
  const router = useRouter();

  useEffect(() => {
    Linking.getInitialURL().then((url) => {
      if (url) supabase.auth.exchangeCodeForSession(url);
    });

    const sub = Linking.addEventListener("url", ({ url }) => {
      supabase.auth.exchangeCodeForSession(url);
    });

    return () => sub.remove();
  }, []);

  useEffect(() => {
    const fetchUser = async () => {
      const { data } = await supabase.auth.getUser();
      if (data?.user) router.replace("/(tabs)/home");
    };
    fetchUser();

    const { data } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        router.replace("/(tabs)/home");
      }
    });

    return () => data.subscription?.unsubscribe?.();
  }, []);

  return (
    <View style={{ flex: 1 }}>
      <Auth />
    </View>
  );
}
