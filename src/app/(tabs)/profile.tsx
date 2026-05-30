import { useRouter } from "expo-router";
import { useEffect, useState } from "react";
import { View } from "react-native";
import Account from "../../components/Account";
import { supabase } from "../lib/supabase";

export default function Profile() {
  const [userId, setUserId] = useState<string | null>(null);
  const [email, setEmail] = useState<string | undefined>(undefined);
  const router = useRouter();

  useEffect(() => {
    const fetchUser = async () => {
      const { data } = await supabase.auth.getUser();
      const user = data?.user ?? null;
      if (user) {
        setUserId(user.id);
        setEmail(user.email ?? undefined);
      } else {
        router.replace("/");
      }
    };
    fetchUser();

    const { data } = supabase.auth.onAuthStateChange((_event, session) => {
      if (!session?.user) router.replace("/");
    });

    return () => data.subscription?.unsubscribe?.();
  }, []);

  return (
    <View style={{ flex: 1 }}>
      {userId && <Account key={userId} userId={userId} email={email} />}
    </View>
  );
}
