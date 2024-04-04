import javax.crypto.spec.SecretKeySpec;
import java.security.Key;
import java.security.NoSuchAlgorithmException;

public class KeyRandomInit {
  public static void main(String[] args) throws NoSuchAlgorithmException {
    String keyString = "AngryBirds12345G";
    Key key = new SecretKeySpec("AngryBirds12345G".getBytes(), "AES");

    // Получение байтового представления ключа
    byte[] keyBytes = key.getEncoded();

    // Преобразование байтового ключа в строку в шестнадцатеричном формате
    StringBuilder keyHexString = new StringBuilder();
    for (byte b : keyBytes) {
      keyHexString.append(String.format("%02X", b));
    }

    System.out.println("Сгенерированный ключ для AES: " + keyHexString.toString());
  }
}