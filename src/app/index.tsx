import { useEffect, useState } from "react";
import { View } from "react-native";
import Account from "../components/Account";
import Auth from "../components/Auth";
import { supabase } from "./lib/supabase";

import * as Linking from "expo-linking";

export default function Index() {
  const [userId, setUserId] = useState<string | null>(null);
  const [email, setEmail] = useState<string | undefined>(undefined);

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
    // Fetch current user
    const fetchUser = async () => {
      const { data } = await supabase.auth.getUser();
      const user = data?.user ?? null;
      if (user) {
        setUserId(user.id);
        setEmail(user.email ?? undefined);
      }
    };
    fetchUser();

    // Listen for auth state changes
    const { data } = supabase.auth.onAuthStateChange((_event, session) => {
      const user = session?.user ?? null;
      if (user) {
        setUserId(user.id);
        setEmail(user.email ?? undefined);
      } else {
        setUserId(null);
        setEmail(undefined);
      }
    });

    return () => {
      // unsubscribe listener
      data.subscription?.unsubscribe?.();
    };
  }, []);

  return (
    <View style={{ flex: 1 }}>
      {userId ? (
        <Account key={userId} userId={userId} email={email} />
      ) : (
        <Auth />
      )}
    </View>
  );
}
