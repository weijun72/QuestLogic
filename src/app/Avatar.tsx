import React from 'react'
import { Image, View, StyleSheet } from 'react-native'

type Props = {
  url?: string | null
  size?: number
}

export default function Avatar({ url, size = 80 }: Props) {
  return (
    <View style={[styles.container, { width: size, height: size, borderRadius: size / 2 }]}> 
      {url ? (
        <Image source={{ uri: url }} style={[styles.image, { width: size, height: size, borderRadius: size / 2 }]} />
      ) : (
        <View style={[styles.placeholder, { width: size, height: size, borderRadius: size / 2 }]} />
      )}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    overflow: 'hidden',
  },
  image: {
    resizeMode: 'cover',
  },
  placeholder: {
    backgroundColor: '#cbd5e1',
  },
})
