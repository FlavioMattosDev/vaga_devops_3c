from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

options = webdriver.ChromeOptions()
options.add_argument("--headless")
options.add_argument("--no-sandbox")
options.add_argument("-disable-dev-shm-usage")

driver = webdriver.Chrome(options=options)
driver.set_window_size(1920, 1080)

driver.get("https://www.cafe3coracoes.com.br")

WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.XPATH, "//*[@id='hdr-srch]/form/input")))

search_input = driver.find_element()