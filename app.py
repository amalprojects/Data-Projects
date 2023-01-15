# AMAL ANTONY PULIMOOTTIL
# 2148371
# project for predicting the price of Asian Options using Monte Carlo simulation and Geometric Brownian Model for price movements





from flask import Flask ,render_template,request
from flaskwebgui import FlaskUI



import numpy as np

#creating a Flask instance
app = Flask(__name__)
# ui = FlaskUI(app)

@app.route("/")
def welcomePage():

    return render_template("firstPage.html")


# Code segment for calculating call option value

@app.route("/call", methods=['POST','GET'])
def call_option():
   Call = ''
   if request.method == 'POST' and 'spotprice' in request.form and 'interestrate'in request.form and 'timePeriod'in request.form and 'volatility'in request.form and 'simulations'in request.form and 'nsteps'in request.form and 'strikePrice' in request.form:
        
        
        spot_Price = float(request.form.get('spotprice'))   
        interest_Rate = float(request.form.get('interestrate'))  
        time_Period = float(request.form.get('timePeriod')) 
        volatility = float(request.form.get('volatility'))  
        simulations = int(request.form.get('simulations'))  
        steps = int(request.form.get('nsteps'))  
        strike_Price = float(request.form.get('strikePrice'))
        
        dt = time_Period / steps
        drift = (interest_Rate - (volatility**2)/2)*dt
        a = volatility*np.sqrt(dt)

        # we obtain a matrix which is simulations cross steps
        # simulations are the number of rows in the matrix
        # steps are the number of columns in the matrix
        rand_var = np.random.normal(0,1,(simulations,steps))

        zero_Matrix = np.zeros((simulations,steps))
        zero_Matrix[:,0] = zero_Matrix[:,0] + spot_Price 

        # the code below generates random walks for each simulation
        # this formula below is the geometric brownian motion model as mentioned in the dissertation.
        for i in range(1,steps):
            zero_Matrix[:,i] = zero_Matrix[:,i-1] * np.exp(drift + a*rand_var[:,i])


        # dividing each random walk by the number of timesteps to incorporate the Asian Option characteristic
        result_list = []
        for i in range(0,simulations):
           asian_average = sum(zero_Matrix[i,:])/steps
           result_list.insert(i,asian_average)


        # calculating the value of the option by subtracting it with the strike price
        # we get an array of values. The number of values depends on the number of simulations
        value_Call = []
        
        for i in result_list:

            value_Call.append(i-strike_Price)

        # Since option value cannot be less than zero
        #  we need to eliminate all negative values from the valueCall array
        for i in range(len(value_Call)):
          if value_Call[i] < 0:
           value_Call[i] = 0 
          else:
           value_Call[i]=value_Call[i]

        # dividing by the number of simulations => The monte carlo bit.   
        payOffCall = np.mean(value_Call)

        #Discounting the the payoff value to the present price

        Call = payOffCall * np.exp(-interest_Rate*time_Period)


        
        
   return render_template("index.html", Call = Call)
   
   



# Code segment for caluclating Put option value




@app.route("/put", methods=['POST','GET'])
def put_option():
    Put = ''

    fget = request.form.get
    spot_price = fget('spotprice')
    interest =  fget('interestrate')
    time_period = fget('timePeriod')
    volatility = fget('volatility')
    simulations = fget('simulations')
    nsteps = fget('nsteps')
    strike_price = fget('strikePrice')

    if request.method == 'POST' and spot_price and interest and time_period and volatility and simulations and nsteps and strike_price:
        spot_price = float(spot_price)
        interest = float(interest)
        time_period = float(time_period)
        volatility = float(volatility)
        simulations = int(simulations)
        nsteps = int(nsteps)
        strike_price= float(strike_price)

        dt = time_period / nsteps
        drift = (interest - (volatility**2)/2)*dt
        a = volatility*np.sqrt(dt)

        # we obtain a matrix which is simulations cross steps
        # simulations are the number of rows in the matrix
        # steps are the number of columns in the matrix
        rand_var = np.random.normal(0,1,(simulations,nsteps))

        zero_Matrix = np.zeros((simulations,nsteps))
        zero_Matrix[:,0] = zero_Matrix[:,0] + spot_price 
        print(zero_Matrix)
        # the code below generates random walks for each simulation

        for i in range(1,nsteps):
            zero_Matrix[:,i] = zero_Matrix[:,i-1] * np.exp(drift + a*rand_var[:,i])


        # dividing each random walk by the number of timesteps to incorporate the Asian Option characteristic
        result_list = []
        for i in range(0,simulations):
           asian_average = sum(zero_Matrix[i,:])/nsteps
           result_list.insert(i,asian_average)


        # calculating the value of the option by subtracting it with the strike price
        # we get an array of values. The number of values depends on the number of simulations
        value_Put = []

        
        for i in result_list:

            value_Put.append(strike_price - i)
        
       # for i in result_list:
       #     x = strike_price-i
            # print(x)
          #  if x > 0:
          #      value_Put.append(x)

        #print(len(value_Put))

        # Since option value cannot be less than zero
        #  we need to eliminate all negative values from the value_Put array
        for i in range(len(value_Put)):
           if value_Put[i] < 0:
            value_Put[i] = 0 
           else:
            value_Put[i]=value_Put[i]

        # dividing by the number of simulations => The monte carlo bit.   
        payOffPut = np.mean(value_Put)

       # print(value_Put)
        #print(payOffPut)

        #Discounting the the payoff value to the present price

        Put = payOffPut * np.exp(-interest*time_period)
        
    return render_template("put.html", Put= Put)

     


   



if __name__ == "__main__":
     app.debug=True
     app.run(host='0.0.0.0')
    #FlaskUI(app=app, server="flask").run()
    # ui.run()