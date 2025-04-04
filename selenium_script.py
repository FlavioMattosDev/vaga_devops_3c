from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

import time

# Configuração das opções do Chrome
options = webdriver.ChromeOptions()
# options.add_argument("--headless")  # Descomente se quiser rodar sem interface gráfica
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

# Inicializa o driver
driver = webdriver.Chrome(options=options)
driver.set_window_size(1920, 1080)

try:
    print("Abrindo o site...")
    driver.get("https://www.cafe3coracoes.com.br")

    # Espera o header carregar
    print("Aguardando carregamento da página (header)...")
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "header"))
    )

    print("✅ Página carregada com sucesso!")
    
    # Captura o título da página e URL
    print("Título da página:", driver.title)
    print("URL atual:", driver.current_url)

    # # Tirar screenshot da tela carregada
    # screenshot_path = "screenshot_home.png"
    # driver.save_screenshot(screenshot_path)
    # print(f"📸 Screenshot salva em: {screenshot_path}")

    # Scroll até o rodapé
    print("Fazendo scroll até o rodapé...")
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")

    # Aguarda 30 segundos para visualizar a página
    print("⏳ Aguardando 30 segundos antes de fechar...")
    time.sleep(30)

except Exception as e:
    print("❌ Ocorreu um erro ao tentar interagir com o site:", e)

finally:
    print("Fechando o navegador...")
    driver.quit()
